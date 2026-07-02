#!/bin/bash
# ============================================================
# CordysCRM — 一键部署（使用预编译自定义镜像）
# 用法: bash Deploy/repair-cordys-server.sh [镜像文件]
#       bash Deploy/repair-cordys-server.sh /path/to/cordys-crm.tar.gz
# ============================================================
set -e

APP_CONTAINER="cordys-crm-1.7.0"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/cordys-1.7.0}"
CUSTOM_IMAGE="kevinchim/cordys-crm:v1.7.2-custom"
NETWORK_NAME="cordyscrm_cordyscrm_default"
IMAGE_FILE="${1:-$HOME/cordys-crm-v1.7.2-custom.tar.gz}"

echo "========================================="
echo " CordysCRM — 部署自定义镜像"
echo "========================================="

# 0. 如果提供了镜像文件，先导入
if [ -f "$IMAGE_FILE" ]; then
    echo "[0/3] 导入镜像..."
    docker load < "$IMAGE_FILE"
    echo "  ✅ 镜像已导入"
else
    echo "⚠️  未找到镜像文件 $IMAGE_FILE"
    echo "   尝试使用本地镜像..."
fi

# 1. 停止旧容器
echo "[1/3] 停止旧容器..."
docker stop $APP_CONTAINER 2>/dev/null || true
docker rm $APP_CONTAINER 2>/dev/null || true

# 2. 清理旧 overlay（不再需要）
rm -rf "$DEPLOY_DIR/app-overlay" "$DEPLOY_DIR/0-crm-main.jar" "$DEPLOY_DIR/0-framework-main.jar" 2>/dev/null || true

# 3. 启动
echo "[2/3] 启动新容器..."
docker run -d \
  --name $APP_CONTAINER \
  --restart unless-stopped \
  --network $NETWORK_NAME \
  -p 18084:8081 \
  -v $DEPLOY_DIR/conf:/opt/cordys/conf \
  -v $DEPLOY_DIR/logs:/opt/cordys/logs \
  -v $DEPLOY_DIR/data:/opt/cordys/data \
  $CUSTOM_IMAGE

echo "[3/3] 等待启动..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18084/ 2>/dev/null | grep -q "200\|302"; then
        echo "✅ 部署成功！无痕模式访问 http://服务器IP:18084"
        exit 0
    fi
    sleep 2
done
echo "⚠️  检查: docker logs $APP_CONTAINER"
