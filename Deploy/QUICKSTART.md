# CordysCRM 生产环境升级指南

## 架构

```
开发机 (本机)                  生产服务器
┌─────────────────────┐        ┌──────────────────────────────┐
│ 1. 改代码             │        │ 数据库 cordys-mysql (独立容器)  │
│ 2. bash Deploy/      │  scp   │ 缓存 cordys-redis (独立容器)    │
│    build-release.sh  │ ────→ │ App cordys-crm-1.7.0 (自定义镜像)│
│    → 得到 tar.gz     │        │                              │
└─────────────────────┘        │ 数据目录 ~/cordys-1.7.0/       │
                               │   conf/  logs/  data/          │
                               └──────────────────────────────┘
```

**数据库完全独立**，升级时不会丢失任何数据。

## 每次升级步骤（2 步）

### 开发机

```bash
# 代码改完后
bash Deploy/build-release.sh
```

生成文件：`/tmp/cordys-release-YYYYMMDD-HHMM.tar.gz`（约 13MB）

### 生产服务器

```bash
# 1. 解压
tar xzf ~/cordys-release-*.tar.gz

# 2. 执行更新
bash quick-update.sh
```

完事。不用 git、不用 Maven、不用编译。

## 发布包内容

```
cordys-release-*.tar.gz
├── crm-main.jar         # 后端
├── framework-main.jar   # 框架
├── web-dist/            # 前端静态文件
└── quick-update.sh      # 升级脚本（自动替换+重启）
```

## 特殊操作：升级 Docker 镜像

改动了 `app` 模块或 Dockerfile 时才需要：

```bash
# 开发机
docker build --network host -t kevinchim/cordys-crm:v1.7.2-custom -f /tmp/Dockerfile.custom .
docker save kevinchim/cordys-crm:v1.7.2-custom | gzip > /tmp/cordys-crm-v1.7.2-custom.tar.gz
scp /tmp/cordys-crm-v1.7.2-custom.tar.gz basenton@<IP>:~/

# 服务器
docker load < ~/cordys-crm-v1.7.2-custom.tar.gz
docker stop cordys-crm-1.7.0 && docker rm cordys-crm-1.7.0
docker run -d --name cordys-crm-1.7.0 --restart unless-stopped \
  --network cordyscrm_cordyscrm_default -p 18084:8081 \
  -v ~/cordys-1.7.0/conf:/opt/cordys/conf \
  -v ~/cordys-1.7.0/logs:/opt/cordys/logs \
  -v ~/cordys-1.7.0/data:/opt/cordys/data \
  kevinchim/cordys-crm:v1.7.2-custom
```

## 踩坑记录

| # | 问题 | 原因 | 教训 |
|---|------|------|------|
| 1 | 类加载顺序 | 旧镜像 `/app/` 先于我们挂载的 JAR 加载，新类被覆盖 | **不要只挂 JAR**，用自定义镜像彻底解决 |
| 2 | CSRF token 为空 | `AppListener` 未初始化 `SessionUser.secret`，加密失败 | 新配置项要写到 `cordys-crm.properties` |
| 3 | Flyway 不执行 | 迁移文件没在 classpath 上，`docker cp` 路径要正确 | 迁移数据要完整，`INSERT IGNORE` 避免冲突 |
| 4 | 生产无法 git pull | TLS/网络问题 | **用 scp 传发布包**，不依赖 git |
| 5 | 配置缺失 | `allowed.ip.ranges.enabled`、`cordys.secret.key` 等新属性 | 新版本新增的 `commons.properties` 属性要加到生产配置 |

## 数据库迁移

新增表或数据改动，在 `backend/crm/src/main/resources/migration/` 下创建 Flyway 脚本：

```
migration/
├── 1.7.2/ddl/V1.7.2_X__描述.sql      # 建表
└── 1.7.2/dml/V1.7.2_X_Y__描述.sql    # 数据
```

重建发布包后，Flyway 启动时**自动执行**新迁移。

## 字典功能修复记录 (2026-07-07)

### 问题：表单字典字段（SELECT/RADIO）保存后值为空

**根因链**：
1. 后端 `SelectResolver/RadioResolver` 校验 options 时，字典字段的 `options` 为空 → 验证失败
2. 前端 `transformFieldValue` 将字典字段值清空（选项匹配失败）
3. 后端 `optionMap` 对字典字段返回空（`field.getOptions()` 为空）

**修复文件**：

| 文件 | 修改 |
|------|------|
| `backend/.../resolver/field/SelectResolver.java` | dict 字段跳过 `validateOptions` |
| `backend/.../resolver/field/RadioResolver.java` | 同上 |
| `backend/.../service/ModuleFormService.java` | 保存表单时 `resolveDictOptions` 自动填充字典选项 |
| `frontend/.../lib-shared/method/formCreate.ts` | `transformFieldValue` 对 dict 字段跳过选项匹配 |
| `frontend/.../lib-shared/method/formCreate.ts` | `getDisplayFieldText` 回退到 `customOptions` |
| `frontend/.../lib-shared/method/formCreate.ts` | `parseModuleFieldValue` 回退到 `customOptions` |
| `frontend/.../lib-shared/method/formCreate.ts` | `transformData` 的 `optionMap` 为空时回退到 `customOptions` |

### 部署后操作

**必须**在「模块设置 → 客户表单 → 点保存」触发 `resolveDictOptions` 将字典选项写入配置。之后新建的客户字典字段才能正确校验和显示。
