#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 移动端单独部署脚本（临时）
# 功能：仅编译并部署 mobile 前端，不动 web 端
# 用法：bash deploy-mobile.sh
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../deploy.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    exit 1
fi
source "$CONFIG_FILE"

SOURCE_DIR="${SOURCE_DIR:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

APP_CONTAINER="cordys-crm-1.7.0"
COMPILE_CONTAINER="cordys-frontend"

echo "========================================="
echo " Cordys CRM 1.7.0 — 移动端部署"
echo "========================================="
echo "源码目录: $SOURCE_DIR/frontend"
echo "目标容器: $APP_CONTAINER"
echo ""

# ---- Step 1: 准备编译容器 ----
echo "[1/4] 准备编译容器..."
docker start $COMPILE_CONTAINER 2>/dev/null || {
    echo "      创建编译容器..."
    docker run -d --name $COMPILE_CONTAINER node:22 tail -f /dev/null
}
echo ""

# ---- Step 2: 复制源码 & 安装依赖 ----
echo "[2/4] 复制源码并安装依赖..."
docker cp $SOURCE_DIR/frontend $COMPILE_CONTAINER:/tmp/frontend-1.7.0

docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/frontend-1.7.0 && \
    npm install -g pnpm@10 2>/dev/null && \
    pnpm i -w --no-frozen-lockfile
" && echo "      完成" || { echo "      ❌ 失败"; exit 1; }
echo ""

# ---- Step 3: 编译移动端 ----
echo "[3/4] 编译移动端..."
docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/frontend-1.7.0/packages/mobile && \
    pnpm build
" && echo "      编译成功" || { echo "      ❌ 编译失败"; exit 1; }
echo ""

# ---- Step 4: 部署 ----
echo "[4/4] 部署到应用容器..."
rm -rf /tmp/mobile-dist && mkdir -p /tmp/mobile-dist
docker cp $COMPILE_CONTAINER:/tmp/frontend-1.7.0/packages/mobile/dist/. /tmp/mobile-dist/
docker exec $APP_CONTAINER rm -rf /app/static/mobile
docker exec $APP_CONTAINER mkdir -p /app/static/mobile
docker cp /tmp/mobile-dist/. $APP_CONTAINER:/app/static/mobile/
docker restart $APP_CONTAINER

echo ""
echo "========================================="
echo " 移动端部署完成!"
echo "========================================="
echo ""
echo "手机访问 http://localhost:18083 自动跳转移动端"
echo "手动访问 http://localhost:18083/mobile/"
