#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 前端部署脚本
# 功能：编译前端 → 部署静态文件到应用容器
# 用法：bash 03-frontend-deploy.sh
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
echo " Cordys CRM 1.7.0 — 前端部署"
echo "========================================="
echo "源码目录: $SOURCE_DIR/frontend"
echo "目标容器: $APP_CONTAINER"
echo ""

# ---- Step 1: 准备编译容器 ----
echo "[1/5] 准备 Node.js 编译容器..."
COMPILE_CONTAINER="cordys-frontend-1.7.0-builder"

if ! docker ps -a --format '{{.Names}}' | grep -q "^${COMPILE_CONTAINER}$"; then
    echo "      创建编译容器..."
    docker run -d --name $COMPILE_CONTAINER \
        node:22 \
        tail -f /dev/null
fi

docker start $COMPILE_CONTAINER 2>/dev/null || true
echo "      完成"
echo ""

# ---- Step 2: 安装依赖 ----
echo "[2/5] 复制源码并安装依赖..."
docker exec $COMPILE_CONTAINER rm -rf /tmp/frontend-1.7.0 2>/dev/null || true
docker cp $SOURCE_DIR/frontend $COMPILE_CONTAINER:/tmp/frontend-1.7.0

docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/frontend-1.7.0 && \
    npm install -g pnpm@10 && \
    pnpm i -w --no-frozen-lockfile
" && echo "      依赖安装完成" || {
    echo "      ❌ 依赖安装失败"
    exit 1
}
echo ""

# ---- Step 3: 编译前端 ----
echo "[3/5] 编译前端（约 2-5 分钟）..."
docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/frontend-1.7.0/packages/web && \
    pnpm build
" && echo "      编译成功!" || {
    echo "      ❌ 编译失败，请检查错误信息"
    exit 1
}
echo ""

# ---- Step 3b: 编译移动端 ----
echo "[3b/5] 编译移动端（约 1-2 分钟）..."
docker exec $COMPILE_CONTAINER bash -c "
    cd /tmp/frontend-1.7.0/packages/mobile && \
    pnpm build
" && echo "      移动端编译成功!" || {
    echo "      ❌ 移动端编译失败，请检查错误信息"
    exit 1
}
echo ""

# ---- Step 4: 部署到应用容器 ----
echo "[4/5] 部署前端文件到应用容器..."

# 复制 web dist 到中转目录
rm -rf /tmp/frontend-1.7.0-dist && mkdir -p /tmp/frontend-1.7.0-dist
docker cp $COMPILE_CONTAINER:/tmp/frontend-1.7.0/packages/web/dist/. /tmp/frontend-1.7.0-dist/

# 部署 web 到应用容器
docker cp /tmp/frontend-1.7.0-dist/. $APP_CONTAINER:/app/static/

# 复制 mobile dist 到中转目录
rm -rf /tmp/frontend-1.7.0-mobile-dist && mkdir -p /tmp/frontend-1.7.0-mobile-dist
docker cp $COMPILE_CONTAINER:/tmp/frontend-1.7.0/packages/mobile/dist/. /tmp/frontend-1.7.0-mobile-dist/

# 部署 mobile 到 /app/static/mobile/
docker exec $APP_CONTAINER rm -rf /app/static/mobile
docker exec $APP_CONTAINER mkdir -p /app/static/mobile
docker cp /tmp/frontend-1.7.0-mobile-dist/. $APP_CONTAINER:/app/static/mobile/

echo "      部署完成（web + mobile）"
echo ""

# ---- Step 5: 重启应用 ----
echo "[5/5] 重启应用容器使前端生效..."
docker restart $APP_CONTAINER
echo "      等待启动..."

sleep 10
if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT/ 2>/dev/null | grep -q "200\|302"; then
    echo "      应用已就绪!"
else
    echo "      应用启动中，请稍后刷新页面"
fi

echo ""
echo "========================================="
echo " 前端部署完成!"
echo "========================================="
echo ""
echo "访问地址: http://服务器IP:$FRONTEND_PORT"
echo ""
echo "提示：如果使用反向代理，请将域名指向端口 $FRONTEND_PORT"
