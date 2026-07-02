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

echo "[1/3] 准备覆盖类..."
OVERLAY_DIR="$DEPLOY_DIR/app-overlay"
rm -rf "$OVERLAY_DIR" && mkdir -p "$OVERLAY_DIR"
cd "$OVERLAY_DIR"

# 解压我们的更新的类
unzip -oqq "$DEPLOY_DIR/crm-main.jar" '*.class' '*.properties' -x 'META-INF/*' 2>/dev/null || true
unzip -oqq "$DEPLOY_DIR/framework-main.jar" '*.class' '*.properties' -x 'META-INF/*' 2>/dev/null || true

# 从运行中的镜像提取基础类（Application 等）
TMP_CONT=$(docker create $BASE_IMAGE 2>/dev/null)
if [ -n "$TMP_CONT" ]; then
    docker cp "$TMP_CONT:/app/cn" "$OVERLAY_DIR/cn-base" 2>/dev/null || true
    docker rm "$TMP_CONT" > /dev/null 2>&1 || true
    # 把基础类目录合并进去（不覆盖已有文件——即我们的更新优先）
    if [ -d "$OVERLAY_DIR/cn-base" ]; then
        cp -rn "$OVERLAY_DIR/cn-base/"* "$OVERLAY_DIR/" 2>/dev/null || true
        rm -rf "$OVERLAY_DIR/cn-base"
    fi
fi

echo "  ✅ 类文件就绪"

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
echo "⚠️  检查: docker logs $APP_CONTAINER"
