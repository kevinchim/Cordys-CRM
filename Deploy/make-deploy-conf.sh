#!/bin/bash
# ============================================================
# CordysCRM — 创建 deploy.conf（生产环境配置）
# 用法: bash Deploy/make-deploy-conf.sh
# 此文件不会进入 git（.gitignore 已排除 deploy.conf）
# ============================================================
set -e

CONF_FILE="$(dirname "$0")/deploy.conf"

cat > "$CONF_FILE" << 'EOF'
# ============================================================
# CordysCRM Deploy 配置文件
# ============================================================

# --- 端口 ---
FRONTEND_PORT=18083
BACKEND_PORT=18084

# --- 容器名称 ---
APP_CONTAINER=cordys-crm-1.7.0
MYSQL_CONTAINER=cordys-mysql
REDIS_CONTAINER=cordys-redis

# --- 数据库 ---
DB_NAME=cordys-crm-1.7.0
DB_USER=root
DB_PASSWORD=root
DB_HOST_PORT=3307

# --- Redis ---
REDIS_HOST_PORT=6379

# --- Docker 网络 ---
NETWORK_NAME=cordyscrm_cordyscrm_default

# --- 基础镜像 ---
BASE_IMAGE=1panel/cordys-crm:v1.7.0

# --- 部署目录（应用数据、日志、配置） ---
DEPLOY_DIR=~/cordys-1.7.0
EOF

echo "✅ 已生成: $CONF_FILE"
echo "   如需修改数据库密码等配置，请编辑此文件后重新部署。"
