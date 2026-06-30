#!/bin/bash
# ============================================================
# CordysCRM - 启动前端开发服务器
# 在 cordys-frontend 容器中启动 Vite dev server
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER="cordys-frontend"
SRC_DIR="/tmp/frontend-1.7.2"
VITE_PORT="5173"
HOST_PORT="18083"
WEB_PACKAGE="${SRC_DIR}/packages/web"

echo "=============================================="
echo "  CordysCRM - 启动前端开发服务器"
echo "=============================================="
echo ""

# 1. 检查容器
echo "[1/4] 检查前端容器 ${CONTAINER}..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "  ❌ 容器 ${CONTAINER} 未运行！"
    exit 1
fi
echo "  ✅ 容器 ${CONTAINER} 运行中"

# 2. 同步前端源码
echo "[2/4] 同步前端源码..."
docker exec ${CONTAINER} bash -c "mkdir -p ${SRC_DIR}" 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/package.json" ${CONTAINER}:${SRC_DIR}/
docker cp "${SCRIPT_DIR}/frontend/pnpm-workspace.yaml" ${CONTAINER}:${SRC_DIR}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/pnpm-lock.yaml" ${CONTAINER}:${SRC_DIR}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/.npmrc" ${CONTAINER}:${SRC_DIR}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/packages" ${CONTAINER}:${SRC_DIR}/

# 确保 install dependencies
docker exec ${CONTAINER} bash -c "cd ${SRC_DIR} && pnpm i -w --no-frozen-lockfile 2>&1 | tail -3"
echo "  ✅ 前端源码同步完成"

# 3. 停止旧进程
echo "[3/4] 停止旧前端进程..."
NODE_PIDS=$(docker exec ${CONTAINER} bash -c "ps aux | grep -E '(vite|esbuild)' | grep -v grep | grep -v defunct | awk '{print \$2}'" 2>/dev/null)
if [ -n "$NODE_PIDS" ]; then
    echo "  发现旧 node 进程: $(echo $NODE_PIDS | tr '\n' ' ')"
    for pid in $NODE_PIDS; do
        docker exec ${CONTAINER} kill "$pid" 2>/dev/null || true
    done
    sleep 2
    REMAINING=$(docker exec ${CONTAINER} bash -c "ps aux | grep -E '(vite|esbuild)' | grep -v grep | grep -v defunct | awk '{print \$2}'" 2>/dev/null)
    if [ -n "$REMAINING" ]; then
        for pid in $REMAINING; do
            docker exec ${CONTAINER} kill -9 "$pid" 2>/dev/null || true
        done
    fi
    echo "  ✅ 旧进程已清理"
else
    echo "  ✅ 无运行中的旧进程"
fi

# 4. 启动 Vite dev server
echo "[4/4] 启动 Vite 开发服务器..."
docker exec -d ${CONTAINER} bash -c "
  cd ${WEB_PACKAGE} && \
  export VITE_DEV_DOMAIN=http://cordys-backend:8081 && \
  nohup pnpm dev --host 0.0.0.0 --port ${VITE_PORT} > /tmp/cordys-frontend.log 2>&1 &
"

# 等待启动
echo "  等待 Vite 启动..."
for i in $(seq 1 20); do
    sleep 2
    if docker exec ${CONTAINER} bash -c "grep -q 'Local:' /tmp/cordys-frontend.log 2>/dev/null" 2>/dev/null; then
        echo "  ✅ Vite 启动成功!"
        break
    fi
    echo "  ⏳ 等待中... (${i}/20)"
done

echo ""
echo "=============================================="
echo "  🎉 前端启动成功!"
echo "=============================================="
echo "  容器:     ${CONTAINER}"
echo "  端口:     ${HOST_PORT} (映射到容器 ${VITE_PORT})"
echo "  日志:     docker exec ${CONTAINER} tail -f /tmp/cordys-frontend.log"
echo "  前端地址: http://localhost:${HOST_PORT}"
echo "=============================================="
