#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 后端部署脚本
# 功能：编译后端 → 部署 JAR → 启动应用容器
# 用法：bash 02-backend-deploy.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/deploy.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    echo "   请确保 deploy.conf 与脚本在同一目录下"
    exit 1
fi
source "$CONFIG_FILE"

# 自动检测路径（deploy.conf 未设置时使用默认值）
if [ -z "$SOURCE_DIR" ]; then SOURCE_DIR="$(dirname "$SCRIPT_DIR")"; fi
if [ -z "$DEPLOY_DIR" ]; then DEPLOY_DIR="$HOME/cordys-1.7.0"; fi


echo "========================================="
echo " Cordys CRM 1.7.0 — 后端部署"
echo "========================================="
echo "源码目录: $SOURCE_DIR"
echo "部署目录: $DEPLOY_DIR"
echo "对外端口: $BACKEND_PORT → 容器 8081"
echo ""

# ---- Step 1: 创建部署目录 ----
echo "[1/6] 创建部署目录..."
mkdir -p $DEPLOY_DIR/{conf,logs/cordys-crm,data/files}
echo "      完成"
echo ""

# ---- Step 2: 编译后端 ----
echo "[2/6] 编译后端（使用 Maven 容器）..."
COMPILE_CONTAINER="cordys-backend-1.7.0-builder"

# 检查或创建编译容器
if ! docker ps -a --format '{{.Names}}' | grep -q "^${COMPILE_CONTAINER}$"; then
    echo "      创建编译容器..."
    docker run -d --name $COMPILE_CONTAINER \
        --network $NETWORK_NAME \
        maven:3.9-eclipse-temurin-21 \
        tail -f /dev/null
fi

# 确保容器运行
docker start $COMPILE_CONTAINER 2>/dev/null || true

# 复制源码到编译容器
echo "      复制源码到编译容器..."
docker cp $SOURCE_DIR $COMPILE_CONTAINER:/tmp/CordysCRM-1.7.0

# 执行编译
echo "      开始编译（约 1-3 分钟）..."
docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/CordysCRM-1.7.0 && \
    ./mvnw install -N -DskipTests -q && \
    ./mvnw install -N --file backend/pom.xml -DskipTests -q && \
    ./mvnw install -pl framework,crm --file backend/pom.xml -DskipTests -DskipAntRunForJenkins -q
" && echo "      编译成功!" || {
    echo "      ❌ 编译失败，请检查错误信息"
    exit 1
}

# 复制 JAR 到部署目录
echo "      复制 JAR 文件..."
docker cp $COMPILE_CONTAINER:/tmp/CordysCRM-1.7.0/backend/crm/target/crm-main.jar $DEPLOY_DIR/
docker cp $COMPILE_CONTAINER:/tmp/CordysCRM-1.7.0/backend/framework/target/framework-main.jar $DEPLOY_DIR/

echo "      完成"
echo ""

# ---- Step 3: 生成配置文件 ----
echo "[3/6] 生成应用配置文件..."
cat > $DEPLOY_DIR/conf/cordys-crm.properties << EOF
# Cordys CRM 1.7.0 配置
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

# 数据库
spring.datasource.url=jdbc:mysql://${MYSQL_CONTAINER}:3306/${DB_NAME}?autoReconnect=false&useUnicode=true&characterEncoding=UTF-8&characterSetResults=UTF-8&zeroDateTimeBehavior=convertToNull&allowPublicKeyRetrieval=true&useSSL=false
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}

# Redis
spring.data.redis.host=${REDIS_CONTAINER}
spring.data.redis.port=6379

# Flyway
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:migration
spring.flyway.table=cordys_crm_version
spring.flyway.validate-on-migrate=false

# 禁用内嵌 MySQL/Redis（使用外部容器）
mysql.embedded.enabled=false
redis.embedded.enabled=false
EOF

echo "      配置文件: $DEPLOY_DIR/conf/cordys-crm.properties"
echo ""

# ---- Step 4: 停止旧容器（如果存在） ----
echo "[4/6] 检查现有容器..."
if docker ps -a --format '{{.Names}}' | grep -q "^${APP_CONTAINER}$"; then
    echo "      停止并删除旧容器 ${APP_CONTAINER}..."
    docker stop $APP_CONTAINER 2>/dev/null || true
    docker rm $APP_CONTAINER 2>/dev/null || true
fi
echo "      完成"
echo ""

# ---- Step 5: 启动应用容器 ----
echo "[5/6] 启动 Cordys CRM 1.7.0 应用容器..."

docker run -d \
    --name $APP_CONTAINER \
    --restart unless-stopped \
    --network $NETWORK_NAME \
    --network-alias $APP_CONTAINER \
    -p $BACKEND_PORT:8081 \
    -v $DEPLOY_DIR/conf:/opt/cordys/conf \
    -v $DEPLOY_DIR/logs:/opt/cordys/logs \
    -v $DEPLOY_DIR/data:/opt/cordys/data \
    -v $DEPLOY_DIR/crm-main.jar:/app/lib/crm-main.jar \
    -v $DEPLOY_DIR/framework-main.jar:/app/lib/framework-main.jar \
    $BASE_IMAGE

echo "      容器已启动"
echo ""

# ---- Step 6: 等待启动 ----
echo "[6/6] 等待应用启动（约 20-30 秒）..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/ 2>/dev/null | grep -q "200\|302"; then
        echo "      应用已就绪!"
        break
    fi
    sleep 2
    echo -n "."
done
echo ""

echo "========================================="
echo " 后端部署完成!"
echo "========================================="
echo ""
echo "访问地址: http://服务器IP:$BACKEND_PORT"
echo "默认账号: admin"
echo "默认密码: CordysCRM"
echo ""
echo "查看日志: docker logs -f $APP_CONTAINER"
echo "查看状态: docker ps --filter name=$APP_CONTAINER"
