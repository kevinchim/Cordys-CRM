# CordysCRM 升级工作流

## Git 架构

```
upstream (1Panel-dev/CordysCRM)     origin (你的私有仓库)
  v1.7.0 ── v1.7.1 ── v1.7.2        master (合并后代码)
                │                       │
                └─── 三方合并 ──────────┘
```

- **`upstream`**: 跟踪上游 CordysCRM 官方版本（`https://github.com/1Panel-dev/CordysCRM.git`）
- **`origin`**: 你的 GitHub 私有仓库（待创建）
- **`upstream` 分支**: 存放上游纯净 tarball 内容，用于三方合并

## 每次上游发布新版本时

### 1. 获取新版本

```bash
VERSION=v1.7.3  # 替换为实际版本

# 下载 tarball
curl -fsSL -o /tmp/cordys-${VERSION}.tar.gz \
  "https://api.github.com/repos/1Panel-dev/CordysCRM/tarball/${VERSION}"

mkdir -p /tmp/cordys-${VERSION}-source
tar xzf /tmp/cordys-${VERSION}.tar.gz -C /tmp/cordys-${VERSION}-source --strip-components=1
```

### 2. 更新 upstream 分支

```bash
git checkout upstream
rsync -a --delete --exclude='.git' --exclude='target' --exclude='node_modules' \
  /tmp/cordys-${VERSION}-source/ ./
git add -A
git commit -m "${VERSION} upstream"
```

### 3. 合并到 master

```bash
git checkout master
git merge upstream -m "merge: upstream ${VERSION} → master"
```

### 4. 处理冲突

```bash
# 查看冲突
git diff --name-only --diff-filter=U

# 自动解决上游删除的文件
git status --porcelain | grep "^DU" | awk '{print $2}' | xargs git rm

# 自动解决双方新增文件（取上游版本）
git status --porcelain | grep "^AA" | awk '{print $2}' | while read f; do
  git checkout --theirs "$f" && git add "$f"
done

# 手动解决内容冲突（UU 文件）
# 编辑冲突文件 → git add → git commit
```

### 5. 构建验证

```bash
# 后端
docker cp . cordys-backend:/tmp/CordysCRM-${VERSION}
docker exec cordys-backend bash -c "
  cd /tmp/CordysCRM-${VERSION} && \
  ./mvnw install -N -DskipTests -q && \
  ./mvnw install -pl framework,crm -DskipTests -DskipAntRunForJenkins -q --file backend/pom.xml
"

# 前端
docker cp frontend cordys-frontend:/tmp/frontend-${VERSION}
docker exec cordys-frontend bash -c "
  cd /tmp/frontend-${VERSION} && \
  pnpm i -w --no-frozen-lockfile && \
  cd packages/web && pnpm build
"
```

### 6. 推送

```bash
git push origin master upstream
```

## v1.7.2 升级记录 (2026-06-29)

### 升级方法
Git 三方合并：以 v1.7.0 为共同祖先，`upstream` 分支包含 v1.7.0→v1.7.1→v1.7.2 纯净升级，merge 到 master。

### 合并统计
- 总冲突文件：95 个
  - 上游删除（DU）：6 个（前端配置文件）→ 已删除
  - 双方新增（AA）：26 个（路径重命名/内容重复）→ 取上游版本
  - 路径冲突（UD/UA/AU）：57 个（SQLBot 模块删除、订单表单重命名）→ 已自动解决
  - 内容冲突（UU）：6 个 → 手动解决

### 手动解决的冲突

| 文件 | 冲突内容 | 解决方案 |
|------|---------|---------|
| `PermissionConstants.java` | DICT_MANAGE vs CUSTOM_FORM 权限常量 | 保留两套 |
| `CustomerPoolService.java` | `Map<>` vs `var` + 排序逻辑 | 取上游版本 |
| `cordys-crm_*.properties` | 公海限制 vs 自定义表单 i18n | 合并两套 |
| `api/modules/index.ts` | 自定义表单导出函数缺失 | 添加新导出 |
| `select.vue` | import 合并 + render-option 重复 | 合并 import，去重 |

### 自定义功能清单（每次升级需检查）

- [x] 公海规则增强（每日/每月查看限制、回收监听）
- [x] Welltrans CRM API 推送
- [x] 字典管理（分类 + 字典项 CRUD）
- [x] 字典颜色显示（select/radio/checkbox 组件）
- [x] 字典数据源（表单设计器 optionSource="dict"）
- [x] 前端自定义页面（dict-manage, welltrans-push）
- [x] i18n 翻译条目

### 注意事项

1. **前端自定义页面**（`dict-manage`, `welltrans-push`）是 untracked 文件，`git stash` 不带 `-u` 会丢失，需从备份恢复
2. **`cordys-1.7.0-source/`** 旧目录在 merge 时会产生大量 rename/delete 冲突，建议后续清理
3. **SQLBot 模块**在 v1.7.2 中被完全移除
4. **`frontend/.git`** 嵌入仓库已在 upstream 分支中清理

## GitHub 仓库设置

```bash
# 1. 在 GitHub 创建私有仓库（例如：cordys-crm-custom）

# 2. 添加 origin remote 并推送
git remote add origin git@github.com:<你的用户名>/cordys-crm-custom.git
git push -u origin master upstream

# 3. 设置默认分支
# GitHub Settings → Branches → Default branch → master
```

## 未来日常开发流程

```bash
# 每次开发前同步上游
git fetch upstream
git log upstream/master..upstream/master --oneline  # 查看上游是否有新版本

# 日常开发
git checkout -b feature/my-feature
# ... 开发 ...
git checkout master && git merge feature/my-feature
git push origin master
```
