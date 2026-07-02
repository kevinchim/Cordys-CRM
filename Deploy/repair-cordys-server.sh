#!/bin/bash
# ============================================================
# CordysCRM — 修复 CSRF / 类加载问题
# 用法: bash Deploy/repair-cordys-server.sh
# ============================================================
set -e

APP_CONTAINER="cordys-crm-1.7.0"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/cordys-1.7.0}"
BASE_IMAGE="1panel/cordys-crm:v1.7.0"
NETWORK_NAME="cordyscrm_cordyscrm_default"

echo "========================================="
echo " CordysCRM — 修复部署"
echo "========================================="

if [ ! -f "$DEPLOY_DIR/crm-main.jar" ]; then
    echo "❌ 未找到 $DEPLOY_DIR/crm-main.jar"
    exit 1
fi

echo "[1/3] 提取类文件..."
OVERLAY_DIR="$DEPLOY_DIR/app-overlay"
rm -rf "$OVERLAY_DIR" && mkdir -p "$OVERLAY_DIR"
cd "$OVERLAY_DIR"
unzip -oqq "$DEPLOY_DIR/crm-main.jar" '*.class' '*.properties' -x 'META-INF/*' 2>/dev/null || true
unzip -oqq "$DEPLOY_DIR/framework-main.jar" '*.class' '*.properties' -x 'META-INF/*' 2>/dev/null || true
echo "  ✅ 已提取 $(find . -name '*.class' | wc -l) 个类文件"

echo "[2/3] 停止旧容器..."
docker stop $APP_CONTAINER 2>/dev/null || true
docker rm $APP_CONTAINER 2>/dev/null || true

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
  $BASE_IMAGE

echo ""
echo "等待启动..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18084/ 2>/dev/null | grep -q "200\|302"; then
        echo "✅ 部署成功！无痕模式访问 http://服务器IP:18084"
        exit 0
    fi
    sleep 2
done
echo "⚠️  启动超时，检查: docker logs $APP_CONTAINER"
