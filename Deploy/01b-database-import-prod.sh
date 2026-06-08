#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 数据库导入脚本（目标服务器）
# 功能：在目标服务器创建新数据库并导入 SQL 文件
# 用法：bash 01b-database-import-prod.sh <导出文件路径>
#
# 示例：
#   bash 01b-database-import-prod.sh /tmp/cordys-crm-1.7.0-export-20260604_120000.sql.gz
#   DB_NAME=my-custom-db bash 01b-database-import-prod.sh /tmp/export.sql.gz
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


# ---- 参数检查 ----
IMPORT_FILE="${1:-}"

if [ -z "$IMPORT_FILE" ]; then
    echo "用法: bash 01b-database-import-prod.sh <导出文件路径>"
    echo ""
    echo "示例:"
    echo "  bash 01b-database-import-prod.sh /tmp/cordys-crm-1.7.0-export-20260604_120000.sql.gz"
    echo ""
    echo "可选环境变量:"
    echo "  DB_NAME=自定义数据库名    # 默认: cordys-crm-1.7.0"
    echo "  MYSQL_CONTAINER=容器名    # 默认: cordys-mysql-1.7.0"
    echo "  DB_USER=用户名            # 默认: root"
    echo "  DB_PASSWORD=密码          # 默认: root"
    exit 1
fi

if [ ! -f "$IMPORT_FILE" ]; then
    echo "❌ 文件不存在: $IMPORT_FILE"
    exit 1
fi

# 源数据库名（从 SQL 文件中提取，或使用环境变量覆盖）
TARGET_DB="${DB_NAME:-cordys-crm-1.7.0}"

echo "========================================="
echo " Cordys CRM 1.7.0 — 数据库导入"
echo "========================================="
echo "导入文件:   $IMPORT_FILE ($(du -h $IMPORT_FILE | cut -f1))"
echo "目标容器:   $MYSQL_CONTAINER"
echo "目标数据库: $TARGET_DB"
echo "MySQL 用户: $DB_USER"
echo ""

# ---- Step 1: 确保 MySQL 容器存在 ----
echo "[1/6] 检查 MySQL 容器..."

if ! docker ps -a --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
    echo "      MySQL 容器 $MYSQL_CONTAINER 不存在，正在创建..."
    docker run -d \
        --name $MYSQL_CONTAINER \
        --restart unless-stopped \
        --network $NETWORK_NAME \
        -p ${DB_PORT}:3306 \
        -e MYSQL_ROOT_PASSWORD=$DB_PASSWORD \
        mysql:8
    echo "      等待 MySQL 启动..."
    sleep 15
elif ! docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
    echo "      启动已有容器..."
    docker start $MYSQL_CONTAINER
    sleep 10
fi

# 等待 MySQL 就绪
echo "      等待 MySQL 就绪..."
for i in $(seq 1 30); do
    if docker exec $MYSQL_CONTAINER mysqladmin ping -u$DB_USER -p$DB_PASSWORD --silent 2>/dev/null; then
        echo "      MySQL 已就绪"
        break
    fi
    sleep 2
done
echo ""

# ---- Step 2: 检查是否已有同名数据库 ----
echo "[2/6] 检查目标数据库..."

DB_EXISTS=$(docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -sN \
    -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$TARGET_DB';" 2>/dev/null)

if [ "$DB_EXISTS" != "0" ] && [ -n "$DB_EXISTS" ]; then
    echo "      ⚠ 数据库 $TARGET_DB 已存在!"
    echo ""
    TABLE_COUNT=$(docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -sN \
        -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$TARGET_DB';" 2>/dev/null)
    echo "      现有表数量: $TABLE_COUNT"
    echo ""
    echo "      选项:"
    echo "        [y] 删除现有数据库并重新导入（数据将丢失）"
    echo "        [n] 取消操作（默认）"
    echo "        [r] 使用不同的数据库名重试"
    echo ""
    read -p "      请选择 [y/n/r]: " CHOICE

    case $CHOICE in
        y|Y)
            echo "      删除现有数据库 $TARGET_DB..."
            docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE \`$TARGET_DB\`;" 2>/dev/null
            ;;
        r|R)
            read -p "      输入新数据库名: " TARGET_DB
            echo "      将使用新数据库名: $TARGET_DB"
            ;;
        *)
            echo "      操作已取消"
            exit 0
            ;;
    esac
fi
echo ""

# ---- Step 3: 创建数据库 ----
echo "[3/6] 创建数据库 $TARGET_DB..."
docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -e \
    "CREATE DATABASE IF NOT EXISTS \`$TARGET_DB\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
echo "      创建完成"
echo ""

# ---- Step 4: 导入数据 ----
echo "[4/6] 导入数据（可能需要几分钟，请耐心等待）..."

if [[ "$IMPORT_FILE" == *.gz ]]; then
    zcat "$IMPORT_FILE" | docker exec -i $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD $TARGET_DB
else
    docker exec -i $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD $TARGET_DB < "$IMPORT_FILE"
fi

echo "      导入完成"
echo ""

# ---- Step 5: 验证导入 ----
echo "[5/6] 验证导入结果..."

IMPORTED_TABLES=$(docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -sN \
    -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$TARGET_DB';" 2>/dev/null)

echo "      数据库: $TARGET_DB"
echo "      表数量: $IMPORTED_TABLES"

if [ "$IMPORTED_TABLES" = "0" ] || [ -z "$IMPORTED_TABLES" ]; then
    echo "      ❌ 导入失败：未检测到表"
    exit 1
fi

echo ""
echo "      表列表:"
docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -e \
    "SELECT TABLE_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$TARGET_DB' ORDER BY TABLE_NAME;" 2>/dev/null
echo ""

# ---- Step 6: 更新配置 ----
echo "[6/6] 检查应用配置文件..."

CONFIG_FILE="$DEPLOY_DIR/conf/cordys-crm.properties"
if [ -f "$CONFIG_FILE" ]; then
    # 更新数据库名
    sed -i "s|spring.datasource.url=.*|spring.datasource.url=jdbc:mysql://${MYSQL_CONTAINER}:3306/${TARGET_DB}?autoReconnect=false\&useUnicode=true\&characterEncoding=UTF-8\&characterSetResults=UTF-8\&zeroDateTimeBehavior=convertToNull\&allowPublicKeyRetrieval=true\&useSSL=false|" "$CONFIG_FILE"
    echo "      已更新配置文件: $CONFIG_FILE"
else
    echo "      ⚠ 配置文件不存在: $CONFIG_FILE"
    echo "      部署后端时会自动生成配置文件"
fi

echo ""
echo "========================================="
echo " 数据库导入完成!"
echo "========================================="
echo ""
echo "目标数据库: $TARGET_DB"
echo "导入表数量: $IMPORTED_TABLES"
echo ""
echo "--- 后续步骤 ---"
echo ""
echo "1. 部署后端:"
echo "   bash 02-backend-deploy.sh"
echo ""
echo "2. 部署前端:"
echo "   bash 03-frontend-deploy.sh"
echo ""
echo "3. 启动服务:"
echo "   bash start-services.sh start"
echo ""
echo "4. 访问应用:"
echo "   http://服务器IP:$FRONTEND_PORT"
echo "   默认账号: admin / CordysCRM"
