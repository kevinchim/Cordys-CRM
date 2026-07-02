#!/bin/bash
# ============================================================
# CordysCRM — 修复 CSRF / 类加载问题
# 用法: bash Deploy/repair-cordys-server.sh
#
# 根因: 启动脚本硬编码 JAVA_CLASSPATH=/app:/app/lib/*
#       /app 目录先于我们的 JAR，旧类覆盖新类
# 修复: 解压 JAR 中的类到 /app/ 覆盖旧类
# ============================================================
set -e

APP_CONTAINER="cordys-crm-1.7.0"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/cordys-1.7.0}"
BASE_IMAGE="1panel/cordys-crm:v1.7.0"
NETWORK_NAME="cordyscrm_cordyscrm_default"

echo "========================================="
echo " CordysCRM — 修复部署"
echo "========================================="

# 确保有最新 JAR
if [ ! -f "$DEPLOY_DIR/crm-main.jar" ]; then
    echo "❌ 未找到 $DEPLOY_DIR/crm-main.jar"
    echo "   请先运行: bash Deploy/02-backend-deploy.sh"
    exit 1
fi

# 1. 解压类文件到 app-overlay 目录
echo "[1/3] 提取更新的类文件..."
OVERLAY_DIR="$DEPLOY_DIR/app-overlay"
rm -rf "$OVERLAY_DIR" && mkdir -p "$OVERLAY_DIR"

# 从 JAR 解压所有 .class 和 .properties 文件
cd "$OVERLAY_DIR"
unzip -o "$DEPLOY_DIR/crm-main.jar" '*.class' '*.properties' -x 'META-INF/*' > /dev/null 2>&1 || true
unzip -o "$DEPLOY_DIR/framework-main.jar" '*.class' '*.properties' -x 'META-INF/*' > /dev/null 2>&1 || true

echo "  ✅ 已提取 $(find "$OVERLAY_DIR" -name '*.class' | wc -l) 个类文件"

# 2. 停止并删除旧容器
echo "[2/3] 停止旧容器..."
docker stop $APP_CONTAINER 2>/dev/null || true
docker rm $APP_CONTAINER 2>/dev/null || true
echo "  ✅ 已清理"

# 3. 启动新容器，挂载 overlay 目录在类路径最前面
echo "[3/3] 启动容器..."
docker run -d \
  --name $APP_CONTAINER \
  --restart unless-stopped \
  --network $NETWORK_NAME \
  -p 18084:8081 \
  -v $DEPLOY_DIR/conf:/opt/cordys/conf \
  -v $DEPLOY_DIR/logs:/opt/cordys/logs \
  -v $DEPLOY_DIR/data:/opt/cordys/data \
  -v $OVERLAY_DIR/cn:/app/cn \
  -v $OVERLAY_DIR/META-INF:/app/META-INF 2>/dev/null || true \
  -v $OVERLAY_DIR/cn:/app/cn \
  $BASE_IMAGE

echo ""
echo "等待应用启动..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18084/ 2>/dev/null | grep -q "200\|302"; then
        echo "✅ 部署成功！"
        echo ""
        echo "  无痕模式登录: http://服务器IP:18084"
        echo "  账号: admin  密码: CordysCRM"
        exit 0
    fi
    sleep 2
done
echo "⚠️  应用启动中，请稍后检查 docker logs cordys-crm-1.7.0"
