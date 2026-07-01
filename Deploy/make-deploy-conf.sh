#!/bin/bash
# ============================================================
# CordysCRM — 创建 deploy.conf（生产环境配置）
# 用法: bash Deploy/make-deploy-conf.sh
#
# 说明:
#   - 此脚本生成的配置连接的是【现有外部数据库容器】
#   - 不会创建新的 MySQL/Redis，不会影响现有数据
#   - 部署脚本 02-backend-deploy.sh 仅重建 app 容器和 JAR
#   - deploy.conf 已加入 .gitignore，不会泄露到 Git
# ============================================================
set -e

CONF_FILE="$(dirname "$0")/deploy.conf"

# === 自动检测现有容器（如果存在） ===
DETECT_MYSQL=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -i 'mysql' | head -1 || echo 'cordys-mysql')
DETECT_REDIS=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -i 'redis' | head -1 || echo 'cordys-redis')
DETECT_APP=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -i 'cordys-crm\|cordys-crm-1.7' | head -1 || echo 'cordys-crm-1.7.0')
DETECT_NET=$(docker inspect "$DETECT_APP" --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null || echo 'cordyscrm_cordyscrm_default')

echo "============================================"
echo "  CordysCRM — 生成部署配置"
echo "============================================"
echo ""
echo "  检测到现有容器:"
echo "    MySQL  : $DETECT_MYSQL"
echo "    Redis  : $DETECT_REDIS"
echo "    App    : $DETECT_APP"
echo "    网络   : $DETECT_NET"
echo ""
echo "  ⚠️  数据库【不会被影响】— 仅连接现有容器"
echo ""

cat > "$CONF_FILE" << EOF
# ============================================================
# CordysCRM Deploy 配置文件
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')
# ============================================================

# --- 端口 ---
FRONTEND_PORT=18083
BACKEND_PORT=18084

# --- 容器名称（复用现有容器） ---
APP_CONTAINER=$DETECT_APP
MYSQL_CONTAINER=$DETECT_MYSQL
REDIS_CONTAINER=$DETECT_REDIS

# --- 数据库（连接现有 MySQL 容器，不影响数据） ---
DB_NAME=cordys-crm-1.7.0
DB_USER=root
DB_PASSWORD=root
DB_HOST_PORT=3307

# --- Redis ---
REDIS_HOST_PORT=6379

# --- Docker 网络 ---
NETWORK_NAME=$DETECT_NET

# --- 基础镜像（仅用于容器启动参考，实际 JAR 由编译生成） ---
BASE_IMAGE=1panel/cordys-crm:v1.7.0

# --- 部署目录（应用日志/文件/配置，不含数据库） ---
DEPLOY_DIR=~/cordys-1.7.0
EOF

echo "✅ 已生成: $CONF_FILE"
echo ""
echo "  📋 下一步:"
echo "    bash Deploy/02-backend-deploy.sh   # 重新编译部署后端（不影响数据库）"
echo "    bash Deploy/03-frontend-deploy.sh  # 重新编译部署前端"
