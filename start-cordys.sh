#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 启动脚本（重启电脑后使用）
# 用法：bash start-cordys.sh
# ============================================

NETWORK="cordyscrm_cordyscrm_default"

echo "========================================="
echo " Cordys CRM 1.7.0 — 启动服务"
echo "========================================="

# 1. MySQL
echo "[1/4] 启动 MySQL..."
if docker ps --format '{{.Names}}' | grep -q "^cordys-mysql$"; then
    echo "      MySQL 已在运行"
else
    docker start cordys-mysql 2>/dev/null && echo "      MySQL 已启动" || echo "      ❌ MySQL 启动失败"
fi

# 2. Redis
echo "[2/4] 启动 Redis..."
if docker ps --format '{{.Names}}' | grep -q "^cordys-redis$"; then
    echo "      Redis 已在运行"
else
    docker start cordys-redis 2>/dev/null && echo "      Redis 已启动" || echo "      ❌ Redis 启动失败"
fi

# 3. 确保网络存在
echo "[3/4] 检查 Docker 网络..."
if ! docker network ls --format '{{.Name}}' | grep -q "^${NETWORK}$"; then
    docker network create $NETWORK && echo "      网络已创建: $NETWORK"
else
    echo "      网络已存在: $NETWORK"
fi

# 4. 应用容器
echo "[4/4] 启动 Cordys CRM 1.7.0..."
if docker ps --format '{{.Names}}' | grep -q "^cordys-crm-1.7.0$"; then
    echo "      应用已在运行"
else
    docker start cordys-crm-1.7.0 2>/dev/null && echo "      应用已启动" || {
        echo "      ❌ 容器不存在，请先执行部署脚本:"
        echo "         cd Deploy && bash 02-backend-deploy.sh"
        exit 1
    }
fi

# 等待应用就绪
echo ""
echo "等待应用就绪..."
for i in $(seq 1 15); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18083/ 2>/dev/null | grep -q "200\|302"; then
        echo ""
        break
    fi
    sleep 2
    echo -n "."
done

echo ""
echo "========================================="
echo " Cordys CRM 1.7.0 已就绪!"
echo "========================================="
echo ""
echo "  http://localhost:18083"
echo "  账号: admin"
echo "  密码: CordysCRM"
echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "cordys-mysql|cordys-redis|cordys-crm-1.7.0|NAMES"
