#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 启动服务脚本
# 功能：启动 MySQL / Redis / 应用容器
# 用法：bash start-services.sh [start|stop|restart|status]
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/deploy.conf"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 配置文件不存在: $CONFIG_FILE"
    echo "   请确保 deploy.conf 与脚本在同一目录下"
    exit 1
fi
source "$CONFIG_FILE"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

start_mysql() {
    log_info "启动 MySQL..."
    if docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
        log_info "MySQL 已在运行: $MYSQL_CONTAINER"
    else
        docker start $MYSQL_CONTAINER 2>/dev/null || {
            log_error "MySQL 容器 $MYSQL_CONTAINER 不存在，请先创建"
            return 1
        }
        log_info "MySQL 已启动"
    fi
}

start_redis() {
    log_info "启动 Redis..."
    if docker ps --format '{{.Names}}' | grep -q "^${REDIS_CONTAINER}$"; then
        log_info "Redis 已在运行: $REDIS_CONTAINER"
    else
        docker start $REDIS_CONTAINER 2>/dev/null || {
            log_error "Redis 容器 $REDIS_CONTAINER 不存在，请先创建"
            return 1
        }
        log_info "Redis 已启动"
    fi
}

start_app() {
    log_info "启动 Cordys CRM 1.7.0 应用..."
    if docker ps --format '{{.Names}}' | grep -q "^${APP_CONTAINER}$"; then
        log_info "应用已在运行: $APP_CONTAINER"
        log_info "访问: http://localhost:${FRONTEND_PORT}"
    else
        docker start $APP_CONTAINER 2>/dev/null || {
            log_error "应用容器 $APP_CONTAINER 不存在，请先执行 02-backend-deploy.sh"
            return 1
        }
        log_info "应用启动中..."
        log_info "访问: http://localhost:${FRONTEND_PORT}"
    fi
}

stop_app() {
    log_info "停止应用 $APP_CONTAINER..."
    docker stop $APP_CONTAINER 2>/dev/null && log_info "已停止" || log_warn "未在运行"
}

stop_all() {
    log_info "停止所有服务..."
    docker stop $APP_CONTAINER 2>/dev/null && log_info "应用已停止" || true
    docker stop $REDIS_CONTAINER 2>/dev/null && log_info "Redis 已停止" || true
    docker stop $MYSQL_CONTAINER 2>/dev/null && log_info "MySQL 已停止" || true
    log_info "全部已停止"
}

restart_all() {
    log_info "重启所有服务..."
    stop_all
    sleep 3
    start_mysql
    sleep 3
    start_redis
    sleep 2
    start_app
    log_info "重启完成"
}

show_status() {
    echo ""
    echo "========================================="
    echo " Cordys CRM 1.7.0 — 服务状态"
    echo "========================================="
    echo ""
    printf "%-25s %-15s %s\n" "容器" "状态" "端口"
    printf "%-25s %-15s %s\n" "-------------------------" "---------------" "-----"

    for container in $MYSQL_CONTAINER $REDIS_CONTAINER $APP_CONTAINER; do
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            ports=$(docker port $container 2>/dev/null | head -1 | cut -d' ' -f3)
            printf "%-25s %-15s %s\n" "$container" "● 运行中" "${ports:-—}"
        elif docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            printf "%-25s %-15s %s\n" "$container" "○ 已停止" "—"
        else
            printf "%-25s %-15s %s\n" "$container" "✕ 不存在" "—"
        fi
    done

    echo ""
    echo "前端访问: http://localhost:${FRONTEND_PORT}"
    echo "后端健康: http://localhost:${BACKEND_PORT}"
    echo ""
}

# ============================================
# 主入口
# ============================================

ACTION=${1:-start}

case $ACTION in
    start)
        echo "========================================="
        echo " Cordys CRM 1.7.0 — 启动服务"
        echo "========================================="
        start_mysql
        sleep 3
        start_redis
        sleep 2
        start_app
        echo ""
        show_status
        ;;
    stop)
        stop_all
        ;;
    restart)
        restart_all
        ;;
    status)
        show_status
        ;;
    *)
        echo "用法: bash start-services.sh [start|stop|restart|status]"
        echo ""
        echo "  start   — 启动所有服务（默认）"
        echo "  stop    — 停止所有服务"
        echo "  restart — 重启所有服务"
        echo "  status  — 查看服务状态"
        exit 1
        ;;
esac
