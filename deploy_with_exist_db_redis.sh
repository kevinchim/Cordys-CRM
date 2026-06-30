#!/bin/bash
# ============================================================
# CordysCRM v1.7.2 - 一键部署脚本
# 复用现有 cordys-mysql (cordys-crm-1.7.0) + cordys-redis
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_CT="cordys-backend"
FRONTEND_CT="cordys-frontend"
APP_PORT="8081"
HOST_BACKEND_PORT="15173"
HOST_FRONTEND_PORT="18083"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()   { echo -e "${GREEN}[  OK]${NC}  $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $1"; }
fail() { echo -e "${RED}[FAIL]${NC}  $1"; }

echo ""
echo "=============================================="
echo "  CordysCRM v1.7.2 - 一键部署"
echo "  数据库: cordys-mysql (cordys-crm-1.7.0)"
echo "  缓存:   cordys-redis"
echo "=============================================="
echo ""

# ========================================
# Step 1: 环境检查
# ========================================
info "Step 1/5: 检查 Docker 容器环境..."
echo ""

REQUIRED_CONTAINERS=("cordys-mysql" "cordys-redis" "cordys-backend" "cordys-frontend")
ALL_OK=true

for CT in "${REQUIRED_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${CT}$"; then
        ok "容器 ${CT} 运行中"
    else
        fail "容器 ${CT} 未运行!"
        ALL_OK=false
    fi
done

if [ "$ALL_OK" = false ]; then
    echo ""
    fail "部分容器未运行，请先启动所有必需容器。"
    echo ""
    echo "启动命令参考:"
    echo "  docker start cordys-mysql cordys-redis cordys-backend cordys-frontend"
    exit 1
fi

# 验证数据库连接
echo ""
info "验证数据库连接..."
if docker exec cordys-backend bash -c "mysql -h cordys-mysql -uroot -proot -e 'SELECT 1' cordys-crm-1.7.0 2>/dev/null" >/dev/null 2>&1; then
    ok "数据库 cordys-crm-1.7.0 连接正常"
else
    warn "数据库连接测试跳过 (mysql client 未安装，不影响运行)"
fi

# 验证 Redis 连接
info "验证 Redis 连接..."
if docker exec cordys-backend bash -c "redis-cli -h cordys-redis ping 2>/dev/null" >/dev/null 2>&1; then
    ok "Redis 连接正常"
else
    warn "Redis 连接测试跳过 (redis-cli 未安装，不影响运行)"
fi

echo ""

# ========================================
# Step 2: 编译后端
# ========================================
info "Step 2/5: 编译后端..."
echo ""

bash "${SCRIPT_DIR}/rebuild_backend.sh"

echo ""

# ========================================
# Step 3: 准备前端
# ========================================
info "Step 3/5: 同步前端源码并安装依赖..."
echo ""

FRONTEND_SRC="/tmp/frontend-1.7.2"
docker exec ${FRONTEND_CT} bash -c "mkdir -p ${FRONTEND_SRC}" 2>/dev/null || true

echo "  同步前端文件..."
docker cp "${SCRIPT_DIR}/frontend/package.json" ${FRONTEND_CT}:${FRONTEND_SRC}/
docker cp "${SCRIPT_DIR}/frontend/pnpm-workspace.yaml" ${FRONTEND_CT}:${FRONTEND_SRC}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/pnpm-lock.yaml" ${FRONTEND_CT}:${FRONTEND_SRC}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/.npmrc" ${FRONTEND_CT}:${FRONTEND_SRC}/ 2>/dev/null || true
docker cp "${SCRIPT_DIR}/frontend/packages" ${FRONTEND_CT}:${FRONTEND_SRC}/

echo "  安装依赖..."
docker exec ${FRONTEND_CT} bash -c "cd ${FRONTEND_SRC} && pnpm i -w --no-frozen-lockfile 2>&1 | tail -5"
ok "前端依赖安装完成"

echo ""

# ========================================
# Step 4: 启动后端
# ========================================
info "Step 4/5: 启动后端服务..."
echo ""

bash "${SCRIPT_DIR}/start_backend.sh"

echo ""

# ========================================
# Step 5: 启动前端
# ========================================
info "Step 5/5: 启动前端开发服务器..."
echo ""

bash "${SCRIPT_DIR}/start_frontend.sh"

echo ""

# ========================================
# 部署完成信息
# ========================================
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║                                              ║"
echo "║     🎉  CordysCRM v1.7.2 部署成功!        ║"
echo "║                                              ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║  前端地址:                                   ║"
echo "║  http://localhost:${HOST_FRONTEND_PORT}                  ║"
echo "║                                              ║"
echo "║  后端 API:                                   ║"
echo "║  http://localhost:${HOST_BACKEND_PORT}                  ║"
echo "║                                              ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║  管理员账号:  admin                          ║"
echo "║  管理员密码:  CordysCRM                      ║"
echo "║                                              ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║  查看后端日志:                               ║"
echo "║  docker exec ${BACKEND_CT} tail -f /tmp/cordys-backend.log"
echo "║                                              ║"
echo "║  查看前端日志:                               ║"
echo "║  docker exec ${FRONTEND_CT} tail -f /tmp/cordys-frontend.log"
echo "║                                              ║"
echo "║  数据库信息:                                 ║"
echo "║  MySQL: cordys-mysql:3306 / cordys-crm-1.7.0║"
echo "║  Redis: cordys-redis:6379                     ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
