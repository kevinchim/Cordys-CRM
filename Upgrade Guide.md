# CordysCRM 版本升级指南

## 当前环境速查

| URL | 版本 | 说明 |
|-----|------|------|
| `http://localhost:18083` | **1.7.0 完整版** | 1.7.0 前端(含公海UI) + 1.7.0 后端 + cordys-crm-1.7.0 数据库 |
| `http://localhost:18081` | 1.6.x 旧版 | Vite 前端 → 旧版 cordys-backend:8081 |

### 容器布局

| 容器 | 镜像 | 端口 | 数据库 |
|------|------|------|--------|
| cordys-crm-1.7.0 | `1panel/cordys-crm:v1.7.0` | 18083→8081 | cordys-crm-1.7.0 |
| cordys-backend | `maven:3.9-eclipse-temurin-21` | 15173→8081 | cordys-crm |
| cordys-frontend | `node:22` | 18081,18082→5173 | — |
| cordys-mysql | `mysql:8` | 13306→3306 | — |
| cordys-redis | `redis:7` | 16379→6379 | — |

### 代码位置

| 项目 | 路径 |
|------|------|
| **1.7.0 完整项目 (前后端)** | `~/cordys-crm-dev/CordysCRM-1.7.0` |
| 1.7.0 官方源码 (只读参考) | `~/cordys-crm-dev/cordys-1.7.0-source` |
| 1.6.x 旧版 (只读参考) | `~/cordys-crm-dev/CordysCRM` |

### 目录规范

```
~/cordys-crm-dev/
├── CordysCRM-x.x.x/           ← 各版本完整代码 (前端 + 后端统一管理)
│   ├── backend/               ← Java 后端
│   └── frontend/              ← Vue 前端
├── cordys-x.x.x-source/       ← 官方源码 (对比参考，只读)
└── CordysCRM/                 ← 旧版 (提取自定义功能用，不再修改)
```

---

## 升级流程（1.6.x → 1.7.0 为例）

### Step 1: 获取新版本源码

```bash
mkdir -p ~/cordys-crm-dev && cd ~/cordys-crm-dev
curl -fsSL -o cordys-v1.7.0.tar.gz \
  "https://api.github.com/repos/1Panel-dev/CordysCRM/tarball/v1.7.0"
mkdir cordys-1.7.0-source
tar xzf cordys-v1.7.0.tar.gz -C cordys-1.7.0-source --strip-components=1
```

### Step 2: 创建工作目录

```bash
cp -r cordys-1.7.0-source CordysCRM-1.7.0
cd CordysCRM-1.7.0 && git init && git add -A && git commit -m "v1.7.0 clean base"
```

### Step 3: 迁移后端自定义代码

> 从旧项目 `~/cordys-crm-dev/CordysCRM` 复制公海规则相关文件到新项目。
> 原则：新增文件直接复制，配置文件只追加不覆盖。

```bash
SRC=~/cordys-crm-dev/CordysCRM
DST=~/cordys-crm-dev/CordysCRM-1.7.0
BASE=backend/crm/src/main/java/cn/cordys/crm

# 新增文件 (11个)
cp $SRC/$BASE/customer/domain/CustomerPoolDailyViewRecord.java $DST/$BASE/customer/domain/
cp $SRC/$BASE/customer/domain/CustomerPoolViewAllocation.java   $DST/$BASE/customer/domain/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolDailyViewRecordMapper.java  $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolDailyViewRecordMapper.xml   $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolViewAllocationMapper.java   $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolViewAllocationMapper.xml    $DST/$BASE/customer/mapper/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_3__pool_rule_enhance.sql      $DST/backend/crm/src/main/resources/migration/1.7.0/ddl/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_4__pool_monthly_limit.sql     $DST/backend/crm/src/main/resources/migration/1.7.0/ddl/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_5__clue_pool_monthly_limit.sql $DST/backend/crm/src/main/resources/migration/1.7.0/ddl/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_6__pool_view_allocation.sql   $DST/backend/crm/src/main/resources/migration/1.7.0/ddl/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/dml/V1.7.0_2_4__approval_status.sql      $DST/backend/crm/src/main/resources/migration/1.7.0/dml/

# 修改过的文件 (27个)
cp $SRC/$BASE/customer/domain/CustomerPoolPickRule.java  $DST/$BASE/customer/domain/
cp $SRC/$BASE/clue/domain/CluePoolPickRule.java          $DST/$BASE/clue/domain/
cp $SRC/$BASE/customer/dto/CustomerPoolPickRuleDTO.java  $DST/$BASE/customer/dto/
cp $SRC/$BASE/clue/dto/CluePoolPickRuleDTO.java          $DST/$BASE/clue/dto/
cp $SRC/$BASE/customer/dto/request/CustomerPageRequest.java $DST/$BASE/customer/dto/request/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolMapper.xml  $DST/$BASE/customer/mapper/
cp $SRC/$BASE/clue/mapper/ExtCluePoolMapper.xml          $DST/$BASE/clue/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerMapper.xml      $DST/$BASE/customer/mapper/
cp $SRC/$BASE/contract/mapper/ExtContractMapper.java     $DST/$BASE/contract/mapper/
cp $SRC/$BASE/contract/mapper/ExtContractMapper.xml      $DST/$BASE/contract/mapper/
cp $SRC/$BASE/customer/service/CustomerPoolService.java  $DST/$BASE/customer/service/
cp $SRC/$BASE/customer/service/PoolCustomerService.java  $DST/$BASE/customer/service/
cp $SRC/$BASE/clue/service/CluePoolService.java          $DST/$BASE/clue/service/
cp $SRC/$BASE/customer/controller/CustomerPoolController.java  $DST/$BASE/customer/controller/
cp $SRC/$BASE/customer/controller/PoolCustomerController.java  $DST/$BASE/customer/controller/
cp $SRC/backend/crm/src/main/java/cn/cordys/crm/system/constants/RecycleConditionColumnKey.java $DST/backend/crm/src/main/java/cn/cordys/crm/system/constants/
cp $SRC/backend/crm/src/main/java/cn/cordys/crm/system/dto/RuleConditionDTO.java               $DST/backend/crm/src/main/java/cn/cordys/crm/system/dto/
cp $SRC/backend/crm/src/main/java/cn/cordys/crm/system/job/listener/CustomerPoolRecycleListener.java $DST/backend/crm/src/main/java/cn/cordys/crm/system/job/listener/

# i18n (只追加)
cat >> $DST/backend/crm/src/main/resources/i18n/cordys-crm_zh_CN.properties << 'EOF'
customer.daily.view.over=超出每日可看上限!
customer.monthly.view.over=超出每月可看上限!
customer.monthly.pick.over=超出每月领取上限!
customer.view.limit.mutual.exclusion=每日可看与每月可看互斥，只能选择其中一个启用!
customer.view.limit.insufficient=公海客户不足，仅展示 {0} 家
EOF
cat >> $DST/backend/crm/src/main/resources/i18n/cordys-crm_en_US.properties << 'EOF'
customer.daily.view.over=Daily view limit exceeded!
customer.monthly.view.over=Monthly view limit exceeded!
customer.monthly.pick.over=Monthly pick limit exceeded!
customer.view.limit.mutual.exclusion=Daily view and monthly view are mutually exclusive. Only one can be enabled!
customer.view.limit.insufficient=Insufficient pool customers, only {0} displayed
EOF
```

### Step 4: 迁移前端

前端代码已在 `CordysCRM-1.7.0/frontend/` 中，直接从旧版复制公海文件：

```bash
# 复制公海 UI 组件 (7个文件)
FSRC=~/cordys-crm-dev/CordysCRM/frontend/packages/web/src
FDST=~/cordys-crm-dev/CordysCRM-1.7.0/frontend/packages/web/src
cp $FSRC/views/system/module/components/addOrEditPoolDrawer.vue                     $FDST/views/system/module/components/
cp $FSRC/views/system/module/components/customManagement/openSeaDrawer.vue          $FDST/views/system/module/components/customManagement/
cp $FSRC/views/system/module/components/clueManagement/cluePoolDrawer.vue           $FDST/views/system/module/components/clueManagement/
cp $FSRC/views/customer/components/openSeaTable.vue                                  $FDST/views/customer/components/
cp $FSRC/views/customer/components/openSeaOverviewDrawer.vue                         $FDST/views/customer/components/
cp $FSRC/views/clueManagement/cluePool/components/cluePoolTable.vue                  $FDST/views/clueManagement/cluePool/components/
cp $FSRC/views/clueManagement/cluePool/components/cluePoolOverviewDrawer.vue         $FDST/views/clueManagement/cluePool/components/

# Locale 翻译文件 (2个) — 公海 UI 所有 label 的定义
cp $FSRC/views/system/module/locale/zh-CN.ts $FDST/views/system/module/locale/
cp $FSRC/views/system/module/locale/en-US.ts $FDST/views/system/module/locale/

# 更新 TypeScript 类型定义 (lib-shared)
# 需要手动在以下文件中添加自定义字段类型:
# - lib-shared/models/system/module.ts: CluePoolPickRuleParams +6个字段
# - lib-shared/models/customer/index.ts: PickRule +7个字段 (+limitNew +6个自定义)
# - lib-shared/api/modules/system/module.ts: +manualRecycleCustomerPool
# - lib-shared/api/modules/customer.ts: +getAllocationInfo
# - lib-shared/api/requrls/system/module.ts: +ManualRecycleCustomerPoolUrl
# - lib-shared/api/requrls/customer/index.ts: +GetAllocationInfoUrl
# - web/src/api/modules/index.ts: +manualRecycleCustomerPool, +getAllocationInfo 导出
```

### Step 5: 构建

```bash
# 后端 (通过 Docker)
docker cp CordysCRM-1.7.0 cordys-backend:/tmp/CordysCRM-1.7.0
docker exec cordys-backend bash -c "
cd /tmp/CordysCRM-1.7.0
./mvnw install -N -DskipTests -q
./mvnw install -N --file backend/pom.xml -DskipTests -q
./mvnw install -pl framework,crm --file backend/pom.xml -DskipTests -DskipAntRunForJenkins -q
"
docker cp cordys-backend:/tmp/CordysCRM-1.7.0/backend/crm/target/crm-main.jar ~/cordys-1.7.0/
docker cp cordys-backend:/tmp/CordysCRM-1.7.0/backend/framework/target/framework-main.jar ~/cordys-1.7.0/

# 前端 (通过 Docker, 从统一目录 CordysCRM-1.7.0/frontend/)
docker cp CordysCRM-1.7.0/frontend cordys-frontend:/tmp/frontend-1.7.0
docker exec cordys-frontend bash -c "
cd /tmp/frontend-1.7.0 && pnpm i -w && cd packages/web && pnpm build
"
mkdir -p /tmp/frontend-dist-170
docker cp cordys-frontend:/tmp/frontend-1.7.0/packages/web/dist/. /tmp/frontend-dist-170/
```

### Step 6: 数据库

```bash
docker exec cordys-mysql mysql -uroot -proot -e \
  "CREATE DATABASE IF NOT EXISTS \`cordys-crm-1.7.0\` DEFAULT CHARACTER SET utf8mb4;"
```

### Step 7: 部署

```bash
# 配置
mkdir -p ~/cordys-1.7.0/{conf,logs/cordys-crm,data/files}
cat > ~/cordys-1.7.0/conf/cordys-crm.properties << 'EOF'
spring.datasource.url=jdbc:mysql://cordys-mysql:3306/cordys-crm-1.7.0?autoReconnect=false&useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=root
spring.datasource.password=root
spring.data.redis.host=cordys-redis
spring.data.redis.port=6379
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:migration
spring.flyway.table=cordys_crm_version
spring.flyway.validate-on-migrate=false
mysql.embedded.enabled=false
redis.embedded.enabled=false
EOF

# 启动容器
docker run -d \
  --name cordys-crm-1.7.0 \
  --restart unless-stopped \
  --network cordyscrm_cordyscrm_default \
  --network-alias cordys-crm-170 \
  -p 18083:8081 \
  -v ~/cordys-1.7.0/conf:/opt/cordys/conf \
  -v ~/cordys-1.7.0/logs:/opt/cordys/logs \
  -v ~/cordys-1.7.0/data:/opt/cordys/data \
  -v ~/cordys-1.7.0/crm-main.jar:/app/lib/crm-main.jar \
  -v ~/cordys-1.7.0/framework-main.jar:/app/lib/framework-main.jar \
  1panel/cordys-crm:v1.7.0

# 部署前端静态文件
docker cp /tmp/frontend-dist-170/. cordys-crm-1.7.0:/app/static/
```

### Step 8: 验证

```bash
# 基础
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18083/

# 登录
curl -s -X POST http://localhost:18083/login -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"CordysCRM","authenticate":"","platform":"WEB"}'

# 自定义表
docker exec cordys-mysql mysql -uroot -proot cordys-crm-1.7.0 \
  -e "SHOW TABLES LIKE '%pool%view%'; SHOW TABLES LIKE '%pool%alloc%';"
```

---

## 踩坑记录

| # | 问题 | 原因 | 解决 |
|---|------|------|------|
| 1 | GitHub TLS 握手失败 | 直连 Git 被墙 | `curl -fsSL` + GitHub API tarball |
| 2 | Docker 提取源码启动了完整服务 | entrypoint 未覆盖 | `--entrypoint sh` |
| 3 | 复制文件混入非自定义变更 | 旧文件含无关改动 | diff 检查 + 手动恢复 |
| 4 | i18n 覆盖导致丢失 1.7.0 key | cp 替换了整个文件 | `cat >>` 只追加 |
| 5 | 编译报 `cannot find symbol` | 遗漏 DTO 字段 | 编译错误提示补充 |
| 6 | Node.js `ERR_INVALID_URL` | 容器名 `.0` 被误判为 IP | `--network-alias` 用不含点别名 |
| 7 | Vite 进程僵尸 | `docker exec -d` 子进程 defunct | `pkill -f vite` 后重启 |
| 8 | 前端构建 TS 类型错误 | 1.7.0 类型定义缺自定义字段 | 更新 lib-shared 类型接口 |
| 9 | 跨容器 `docker cp` 失败 | Docker 不支持 | host 中转: `cp → host → target` |
| 10 | 公海 label 显示 key 不显示中文 | 漏了 locale 翻译文件 | 迁移 `locale/zh-CN.ts` + `en-US.ts` |
| 11 | 前端目录分散两处 | 前后端各自独立目录 | 统一到 `CordysCRM-x.x.x/frontend/` |
| 12 | Welltrans 编译报 `isNotNull` 不存在 | `LambdaQueryWrapper` 无此方法 | 改用 Java stream filter |
| 13 | Welltrans POST 保存配置报 405 | `Parameter` 表主键是 `param_key`，`updateById` 按 `id` 列匹配失败 | 改为 `deleteByLambda` + `insert` |
| 14 | Welltrans 只推送电话不推送邮箱 | 邮箱存储在 `customer_contact_field` 自定义字段表 | 查询 `customer_contact_field` 获取邮箱 |
| 15 | Welltrans sales 字段传用户 ID 而非姓名 | `customer.owner` 是用户 ID | 查询 `sys_user` 表获取用户姓名 |

---

## Welltrans CRM API 推送 (v1.7.0 新增功能)

### 功能概述

将 Cordys CRM 中所有有归属的客户数据推送到外部 Welltrans CRM 系统。支持自动回收/手动回收时按开关配置自动推送，也支持在管理界面手动触发推送。

### 新增文件 (10个)

**后端 (7个):**
```
backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_7__welltrans_push_log.sql  — 推送日志表 DDL
backend/crm/src/main/java/cn/cordys/crm/system/domain/WelltransPushLog.java           — 推送日志 Domain
backend/crm/src/main/java/cn/cordys/crm/system/dto/WelltransPushConfigDTO.java        — 配置 DTO
backend/crm/src/main/java/cn/cordys/crm/system/dto/WelltransCustomerDTO.java          — 推送客户数据 DTO
backend/crm/src/main/java/cn/cordys/crm/system/dto/WelltransPushResultDTO.java        — 推送结果 DTO
backend/crm/src/main/java/cn/cordys/crm/system/service/WelltransPushService.java      — 核心推送服务
backend/crm/src/main/java/cn/cordys/crm/system/controller/WelltransPushController.java — REST 控制器
```

**前端 (3个):**
```
frontend/packages/web/src/views/system/welltrans-push/index.vue          — 管理页面
frontend/packages/web/src/views/system/welltrans-push/locale/zh-CN.ts     — 中文翻译
frontend/packages/web/src/views/system/welltrans-push/locale/en-US.ts     — 英文翻译
```

### 修改文件 (9个)

**后端 (1个):**
```
backend/crm/src/main/java/cn/cordys/crm/system/job/listener/CustomerPoolRecycleListener.java
  → +注入 WelltransPushService
  → +triggerAutoPush(pools) — 自动回收后按开关触发推送
  → +triggerManualPush(pool) — 手动回收后按开关触发推送
```

**前端 (8个):**
```
frontend/packages/lib-shared/api/requrls/system/business.ts     → +4个 API URL 常量
frontend/packages/lib-shared/api/modules/system/business.ts     → +4个 API 函数 (import+fn+export)
frontend/packages/lib-shared/models/system/business.ts         → +3个 TS 接口 (Config/Result/Log)
frontend/packages/web/src/enums/routeEnum.ts                   → +SYSTEM_WELLTRANS_PUSH 枚举
frontend/packages/web/src/router/routes/modules/system.ts      → +welltrans-push 路由子节点
frontend/packages/web/src/locale/zh-CN/index.ts                → +菜单 locale 'menu.settings.welltransPush'
frontend/packages/web/src/locale/en-US/index.ts                → +菜单 locale 'menu.settings.welltransPush'
frontend/packages/web/src/api/modules/index.ts                 → +4个 Welltrans 函数导出
```

### 数据库

Flyway 自动执行 `V1.7.0_7__welltrans_push_log.sql` 创建 `sys_welltrans_push_log` 表。

### 配置 (sys_parameter 表)

| param_key | 说明 |
|-----------|------|
| `welltrans.api.url` | Welltrans API 地址 |
| `welltrans.api.key` | API Key |
| `welltrans.auto.push.enabled` | 自动回收时自动推送 |
| `welltrans.manual.push.enabled` | 手动回收时自动推送 |

### 菜单

系统 → Welltrans CRM API 推送 (权限: `SYSTEM_SETTING:READ`)

### 外部 API

`POST {apiUrl}` → `https://welltrans-logistics.com/crm/api/crm_push_emails.php`
- Header: `X-CRM-Api-Key`
- Body: `{"customers": [{email, sales, type, iscooperated, isfullemailaddress, create_date}]}`

---

## 回滚

```bash
docker stop cordys-crm-1.7.0 && docker rm cordys-crm-1.7.0
# 旧版 15173 和 cordys-crm 数据库完全不受影响
```
