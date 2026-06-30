#!/bin/bash
# ============================================================
# CordysCRM - 启动后端服务
# 在 cordys-backend 容器中启动 Spring Boot 应用
# 使用 cordys-mysql (cordys-crm-1.7.0) 和 cordys-redis
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER="cordys-backend"
SRC_DIR="/tmp/CordysCRM-1.7.2"
APP_PORT="8081"
HOST_PORT="15173"
CONFIG_FILE="/tmp/cordys-crm-app.properties"

echo "=============================================="
echo "  CordysCRM - 启动后端服务"
echo "=============================================="
echo ""

# 1. 检查容器
echo "[1/5] 检查构建容器 ${CONTAINER}..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "  ❌ 容器 ${CONTAINER} 未运行！"
    exit 1
fi
echo "  ✅ 容器 ${CONTAINER} 运行中"

# 2. 检查 MySQL 和 Redis
echo "[2/5] 检查 MySQL / Redis 容器..."
for SVC in cordys-mysql cordys-redis; do
    if ! docker ps --format '{{.Names}}' | grep -q "^${SVC}$"; then
        echo "  ❌ 容器 ${SVC} 未运行！"
        exit 1
    fi
done
echo "  ✅ cordys-mysql + cordys-redis 运行中"

# 3. 生成配置文件
echo "[3/5] 生成应用配置..."
docker exec ${CONTAINER} bash -c "cat > ${CONFIG_FILE} << 'PROPEOF'
# ====== 数据源配置 (使用外部 MySQL) ======
mysql.embedded.enabled=false
spring.datasource.url=jdbc:mysql://cordys-mysql:3306/cordys-crm-1.7.0?autoReconnect=false&useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&useSSL=false&sessionVariables=sql_mode=%27STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION%27
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# ====== Redis 配置 (使用外部 Redis) ======
redis.embedded.enabled=false
spring.data.redis.host=cordys-redis
spring.data.redis.port=6379
spring.data.redis.password=

# ====== Flyway 数据库迁移 ======
spring.flyway.enabled=true
spring.flyway.locations=classpath:migration
spring.flyway.table=cordys_crm_version
spring.flyway.validate-on-migrate=false

# ====== 会话配置 ======
spring.session.timeout=30d
spring.session.redis.repository-type=indexed

# ====== 日志 ======
logger.sql.level=info

# ====== MCP Server (可选) ======
mcp.embedded.enabled=false

# ====== 应用端口 ======
server.port=${APP_PORT}

# ====== 其他 ======
spring.freemarker.check-template-location=false
spring.groovy.template.check-template-location=false
management.endpoints.enabled-by-default=false
springdoc.api-docs.groups.enabled=true
dashboard.whitelist.enabled=false
PROPEOF"
echo "  ✅ 配置文件已生成: ${CONFIG_FILE}"

# 4. 停止旧进程
echo "[4/5] 停止旧后端进程..."
docker exec ${CONTAINER} bash -c "pkill -f 'crm-main.jar' 2>/dev/null || true; pkill -f 'spring.config.location' 2>/dev/null || true"
sleep 2
# 强制清理僵尸进程
docker exec ${CONTAINER} bash -c "pkill -9 -f 'crm-main.jar' 2>/dev/null || true"
echo "  ✅ 旧进程已清理"

# 5. 启动应用
echo "[5/5] 启动 Spring Boot 应用..."
JAR_PATH="${SRC_DIR}/backend/crm/target/crm-main.jar"
FRAMEWORK_JAR="${SRC_DIR}/backend/framework/target/framework-main.jar"

# 先检查 JAR 是否存在
if ! docker exec ${CONTAINER} test -f ${JAR_PATH}; then
    echo "  ❌ JAR 文件不存在: ${JAR_PATH}"
    echo "  请先运行 ./rebuild_backend.sh 编译后端"
    exit 1
fi

docker exec -d ${CONTAINER} bash -c "
  nohup java \
    -Dfile.encoding=utf-8 \
    -Djava.awt.headless=true \
    --add-opens java.base/jdk.internal.loader=ALL-UNNAMED \
    --add-opens java.base/java.util=ALL-UNNAMED \
    -server \
    -jar ${JAR_PATH} \
    --spring.config.additional-location=file:${CONFIG_FILE} \
    > /tmp/cordys-backend.log 2>&1 &
"

# 等待启动
echo "  等待应用启动..."
for i in $(seq 1 30); do
    sleep 2
    if docker exec ${CONTAINER} bash -c "curl -s -o /dev/null -w '%{http_code}' http://localhost:${APP_PORT}/ 2>/dev/null" | grep -q "200\|302\|404"; then
        HTTP_CODE=$(docker exec ${CONTAINER} curl -s -o /dev/null -w '%{http_code}' http://localhost:${APP_PORT}/ 2>/dev/null)
        echo "  ✅ 应用启动成功! (HTTP ${HTTP_CODE})"
        break
    fi
    echo "  ⏳ 等待中... (${i}/30)"
done

echo ""
echo "=============================================="
echo "  🎉 后端启动成功!"
echo "=============================================="
echo "  容器:     ${CONTAINER}"
echo "  端口:     ${HOST_PORT} (映射到容器 ${APP_PORT})"
echo "  日志:     docker exec ${CONTAINER} tail -f /tmp/cordys-backend.log"
echo "  后端地址: http://localhost:${HOST_PORT}"
echo "=============================================="
