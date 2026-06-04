# CordysCRM 版本升级指令 (Claude Code)

将当前 CordysCRM 从旧版本升级到新版本，保留所有公海规则自定义功能。

## 目录规范

```
~/cordys-crm-dev/
├── CordysCRM-x.x.x/           ← 各版本完整代码 (前端 + 后端)
│   ├── backend/               ← Java 后端
│   └── frontend/              ← Vue 前端
├── cordys-x.x.x-source/       ← 官方源码 (对比参考，只读)
└── CordysCRM/                 ← 当前旧版 (提取自定义功能用)
```

## 用法

```
@Upgrade Guide-Claude Code 指令.md 升级到 v<新版本号>
```

## 执行

### 1. 获取源码 + 创建工作目录

```bash
VERSION=v1.8.0  # 替换为目标版本
cd ~/cordys-crm-dev
curl -fsSL -o cordys-${VERSION}.tar.gz "https://api.github.com/repos/1Panel-dev/CordysCRM/tarball/${VERSION}"
mkdir cordys-${VERSION}-source && tar xzf cordys-${VERSION}.tar.gz -C cordys-${VERSION}-source --strip-components=1
cp -r cordys-${VERSION}-source CordysCRM-${VERSION}
cd CordysCRM-${VERSION}
git init && git add -A && git commit -m "${VERSION} clean base"
```

### 2. 迁移后端 (从旧版复制公海规则代码)

```bash
SRC=~/cordys-crm-dev/CordysCRM
DST=~/cordys-crm-dev/CordysCRM-${VERSION}
BASE=backend/crm/src/main/java/cn/cordys/crm

# === 新增文件 ===
cp $SRC/$BASE/customer/domain/CustomerPoolDailyViewRecord.java $DST/$BASE/customer/domain/
cp $SRC/$BASE/customer/domain/CustomerPoolViewAllocation.java   $DST/$BASE/customer/domain/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolDailyViewRecordMapper.java  $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolDailyViewRecordMapper.xml   $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolViewAllocationMapper.java   $DST/$BASE/customer/mapper/
cp $SRC/$BASE/customer/mapper/ExtCustomerPoolViewAllocationMapper.xml    $DST/$BASE/customer/mapper/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/*.sql $DST/backend/crm/src/main/resources/migration/${VERSION}/ddl/
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/dml/V1.7.0_2_4__approval_status.sql $DST/backend/crm/src/main/resources/migration/${VERSION}/dml/

# === 修改过的文件 ===
cp $SRC/$BASE/customer/domain/CustomerPoolPickRule.java  $DST/$BASE/customer/domain/
cp $SRC/$BASE/clue/domain/CluePoolPickRule.java          $DST/$BASE/clue/domain/
cp $SRC/$BASE/customer/dto/CustomerPoolPickRuleDTO.java  $DST/$BASE/customer/dto/
cp $SRC/$BASE/clue/dto/CluePoolPickRuleDTO.java          $DST/$BASE/clue/dto/
cp $SRC/$BASE/customer/dto/request/CustomerPageRequest.java  $DST/$BASE/customer/dto/request/
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

# === i18n 只追加不覆盖 ===
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

### 3. 迁移前端 (7 Vue 组件 + 2 Locale + 7 TS 类型)

```bash
FSRC=~/cordys-crm-dev/CordysCRM/frontend/packages/web/src
FDST=~/cordys-crm-dev/CordysCRM-${VERSION}/frontend/packages/web/src

# 公海 UI 组件 (7个)
cp $FSRC/views/system/module/components/addOrEditPoolDrawer.vue                     $FDST/views/system/module/components/
cp $FSRC/views/system/module/components/customManagement/openSeaDrawer.vue          $FDST/views/system/module/components/customManagement/
cp $FSRC/views/system/module/components/clueManagement/cluePoolDrawer.vue           $FDST/views/system/module/components/clueManagement/
cp $FSRC/views/customer/components/openSeaTable.vue                                  $FDST/views/customer/components/
cp $FSRC/views/customer/components/openSeaOverviewDrawer.vue                         $FDST/views/customer/components/
cp $FSRC/views/clueManagement/cluePool/components/cluePoolTable.vue                  $FDST/views/clueManagement/cluePool/components/
cp $FSRC/views/clueManagement/cluePool/components/cluePoolOverviewDrawer.vue         $FDST/views/clueManagement/cluePool/components/

# Locale 翻译文件 (2个)
cp $FSRC/views/system/module/locale/zh-CN.ts $FDST/views/system/module/locale/
cp $FSRC/views/system/module/locale/en-US.ts $FDST/views/system/module/locale/

# TypeScript 类型定义 — 手动在以下 7 个文件中添加自定义字段/函数:
# lib-shared/models/system/module.ts      → CluePoolPickRuleParams +6字段
# lib-shared/models/customer/index.ts     → PickRule +7字段 (+limitNew +6自定义)
# lib-shared/api/modules/system/module.ts → +manualRecycleCustomerPool (import+fn+export)
# lib-shared/api/modules/customer.ts      → +getAllocationInfo (import+fn+export)
# lib-shared/api/requrls/system/module.ts → +ManualRecycleCustomerPoolUrl
# lib-shared/api/requrls/customer/index.ts → +GetAllocationInfoUrl
# web/src/api/modules/index.ts            → +manualRecycleCustomerPool, +getAllocationInfo 导出
```

### 4. diff 检查

```bash
diff -rq ~/cordys-crm-dev/cordys-${VERSION}-source $DST \
  --exclude=".git" --exclude="target" --exclude="node_modules" | grep "differ"
# 逐个确认每个差异都是自定义功能，无意外变更
```

### 5. 构建

```bash
# 后端
docker cp CordysCRM-${VERSION} cordys-backend:/tmp/CordysCRM-${VERSION}
docker exec cordys-backend bash -c "
cd /tmp/CordysCRM-${VERSION}
./mvnw install -N -DskipTests -q && ./mvnw install -N --file backend/pom.xml -DskipTests -q
./mvnw install -pl framework,crm --file backend/pom.xml -DskipTests -DskipAntRunForJenkins -q
"
mkdir -p ~/cordys-${VERSION}/
docker cp cordys-backend:/tmp/CordysCRM-${VERSION}/backend/crm/target/crm-main.jar ~/cordys-${VERSION}/
docker cp cordys-backend:/tmp/CordysCRM-${VERSION}/backend/framework/target/framework-main.jar ~/cordys-${VERSION}/

# 前端 (从统一目录 CordysCRM-${VERSION}/frontend/)
docker cp CordysCRM-${VERSION}/frontend cordys-frontend:/tmp/frontend-${VERSION}
docker exec cordys-frontend bash -c "
cd /tmp/frontend-${VERSION} && pnpm i -w && cd packages/web && pnpm build
"
rm -rf /tmp/frontend-dist-${VERSION} && mkdir -p /tmp/frontend-dist-${VERSION}
docker cp cordys-frontend:/tmp/frontend-${VERSION}/packages/web/dist/. /tmp/frontend-dist-${VERSION}/
```

### 6. 数据库 + 部署

```bash
DB=cordys-crm-${VERSION//./-}
docker exec cordys-mysql mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS \`${DB}\` DEFAULT CHARACTER SET utf8mb4;"

mkdir -p ~/cordys-${VERSION}/{conf,logs/cordys-crm,data/files}
cat > ~/cordys-${VERSION}/conf/cordys-crm.properties << EOF
spring.datasource.url=jdbc:mysql://cordys-mysql:3306/${DB}?autoReconnect=false&useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&useSSL=false
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

CONTAINER=cordys-crm-${VERSION//./-}
docker run -d --name ${CONTAINER} --restart unless-stopped \
  --network cordyscrm_cordyscrm_default --network-alias ${CONTAINER} \
  -p <端口>:8081 \
  -v ~/cordys-${VERSION}/conf:/opt/cordys/conf \
  -v ~/cordys-${VERSION}/logs:/opt/cordys/logs \
  -v ~/cordys-${VERSION}/data:/opt/cordys/data \
  -v ~/cordys-${VERSION}/crm-main.jar:/app/lib/crm-main.jar \
  -v ~/cordys-${VERSION}/framework-main.jar:/app/lib/framework-main.jar \
  1panel/cordys-crm:${VERSION}

# 部署前端静态文件
docker cp /tmp/frontend-dist-${VERSION}/. ${CONTAINER}:/app/static/
```

### 7. 验证

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:<端口>/
curl -s -X POST http://localhost:<端口>/login -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"CordysCRM","authenticate":"","platform":"WEB"}'
docker exec cordys-mysql mysql -uroot -proot ${DB} \
  -e "SHOW TABLES LIKE '%pool%view%'; SHOW TABLES LIKE '%pool%alloc%';"
```

浏览器打开 `http://localhost:<端口>`，登录后进入 **系统设置 → 公海池 → 创建公海**，确认：
- 每日可看限制 / 每月可看限制 / 每月领取限制
- 回收规则 → contractStartTime 条件
- 立即回收客户按钮

### 8. Welltrans CRM API 推送 (v1.7.0 新增功能)

```bash
SRC=~/cordys-crm-dev/CordysCRM
DST=~/cordys-crm-dev/CordysCRM-${VERSION}
BASE=backend/crm/src/main/java/cn/cordys/crm

# === 后端新增文件 ===
cp $SRC/backend/crm/src/main/resources/migration/1.7.0/ddl/V1.7.0_7__welltrans_push_log.sql $DST/backend/crm/src/main/resources/migration/${VERSION}/ddl/
cp $SRC/$BASE/system/domain/WelltransPushLog.java    $DST/$BASE/system/domain/
cp $SRC/$BASE/system/dto/WelltransPushConfigDTO.java  $DST/$BASE/system/dto/
cp $SRC/$BASE/system/dto/WelltransCustomerDTO.java    $DST/$BASE/system/dto/
cp $SRC/$BASE/system/dto/WelltransPushResultDTO.java  $DST/$BASE/system/dto/
cp $SRC/$BASE/system/service/WelltransPushService.java $DST/$BASE/system/service/
cp $SRC/$BASE/system/controller/WelltransPushController.java $DST/$BASE/system/controller/

# === 后端修改文件 ===
cp $SRC/$BASE/system/job/listener/CustomerPoolRecycleListener.java $DST/$BASE/system/job/listener/

# === 前端新增文件 ===
FSRC=~/cordys-crm-dev/CordysCRM/frontend/packages/web/src
FDST=~/cordys-crm-dev/CordysCRM-${VERSION}/frontend/packages/web/src
cp $FSRC/views/system/welltrans-push/index.vue          $FDST/views/system/welltrans-push/
cp $FSRC/views/system/welltrans-push/locale/zh-CN.ts     $FDST/views/system/welltrans-push/locale/
cp $FSRC/views/system/welltrans-push/locale/en-US.ts     $FDST/views/system/welltrans-push/locale/

# === 前端 TypeScript 类型定义 — 手动在以下文件中添加 ===
# lib-shared/api/requrls/system/business.ts     → +4个 API URL
# lib-shared/api/modules/system/business.ts     → +4个 API 函数 (import+fn+export)
# lib-shared/models/system/business.ts         → +3个 TS 接口
# web/src/enums/routeEnum.ts                   → +SYSTEM_WELLTRANS_PUSH
# web/src/router/routes/modules/system.ts      → +welltrans-push 路由子节点
# web/src/locale/zh-CN/index.ts                → +'menu.settings.welltransPush'
# web/src/locale/en-US/index.ts                → +'menu.settings.welltransPush'
# web/src/api/modules/index.ts                 → +4个 Welltrans 函数导出
```

测试: 登录后进入 **系统 → Welltrans CRM API 推送**，配置 API 地址和 Key，开启开关，点击立即执行推送。

---

## 踩坑备忘

| 问题 | 原因 | 解决 |
|------|------|------|
| `git clone` TLS | 网络限制 | `curl -fsSL` + GitHub API tarball |
| Docker 提取源码启动服务 | entrypoint 未覆盖 | `--entrypoint sh` |
| i18n 覆盖丢失 key | cp 整文件 | `cat >>` 追加 |
| 编译 `cannot find symbol` | 遗漏依赖文件 | 按编译错误补上 |
| Node.js `ERR_INVALID_URL` | 容器名含 `.0` | `--network-alias` 不含点 |
| 前端 TS 类型错误 | lib-shared 缺自定义类型 | 更新对应 interface |
| 公海 label 显示 key 不显示中文 | 漏了 locale 翻译文件 | 迁移 locale/zh-CN.ts + en-US.ts |
| 跨容器 `docker cp` | 不支持 | host 中转 |
| Welltrans `isNotNull` 编译错误 | `LambdaQueryWrapper` 无此方法 | 改用 stream filter |
| Welltrans 保存配置 405 | `Parameter.updateById` 按 `id` 列匹配 | 改 `deleteByLambda` + `insert` |
| Welltrans 只推电话不推邮箱 | 邮箱在 `customer_contact_field` 表 | 查询自定义字段获取邮箱 |
| Welltrans sales 传 ID 非姓名 | `customer.owner` 是用户 ID | 查 `sys_user` 获取姓名 |
