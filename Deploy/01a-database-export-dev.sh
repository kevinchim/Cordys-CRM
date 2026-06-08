#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 数据库导出脚本（开发机器）
# 功能：从开发环境 MySQL 容器导出完整数据库为 SQL 文件
# 用法：bash 01a-database-export-dev.sh
# 输出：/tmp/cordys-crm-1.7.0-export-YYYYMMDD_HHMMSS.sql.gz
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

# 源数据库（开发环境）
SOURCE_DB="cordys-crm-1.7.0"
# 如果开发环境数据库名不同，修改此处
# SOURCE_DB="cordys-crm"

EXPORT_FILE="/tmp/${SOURCE_DB}-export-$(date +%Y%m%d_%H%M%S).sql.gz"

echo "========================================="
echo " Cordys CRM 1.7.0 — 数据库导出"
echo "========================================="
echo "源容器:   $MYSQL_CONTAINER"
echo "源数据库: $SOURCE_DB"
echo "导出文件: $EXPORT_FILE"
echo ""

# ---- Step 1: 检查源容器 ----
echo "[1/4] 检查 MySQL 容器..."
if ! docker ps --format '{{.Names}}' | grep -q "^${MYSQL_CONTAINER}$"; then
    echo "      ❌ MySQL 容器 $MYSQL_CONTAINER 未运行"
    echo "      请先启动容器: bash start-services.sh start"
    exit 1
fi
echo "      容器运行中"
echo ""

# ---- Step 2: 检查数据库 ----
echo "[2/4] 检查源数据库..."
DB_EXISTS=$(docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -sN \
    -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$SOURCE_DB';" 2>/dev/null)

if [ "$DB_EXISTS" = "0" ] || [ -z "$DB_EXISTS" ]; then
    echo "      ❌ 数据库 $SOURCE_DB 不存在"
    echo "      可用数据库:"
    docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;" 2>/dev/null
    exit 1
fi

# 统计表数量和记录数
TABLE_COUNT=$(docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -sN \
    -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='$SOURCE_DB';" 2>/dev/null)
echo "      数据库: $SOURCE_DB"
echo "      表数量: $TABLE_COUNT"
echo ""

# ---- Step 3: 导出数据库 ----
echo "[3/4] 导出数据库（可能需要几分钟）..."

docker exec $MYSQL_CONTAINER mysqldump \
    -u$DB_USER -p$DB_PASSWORD \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --add-drop-database \
    --databases $SOURCE_DB \
    | gzip > $EXPORT_FILE

FILE_SIZE=$(du -h $EXPORT_FILE | cut -f1)
echo "      导出完成: $FILE_SIZE"
echo ""

# ---- Step 4: 验证导出 ----
echo "[4/4] 验证导出文件..."
if [ ! -s "$EXPORT_FILE" ]; then
    echo "      ❌ 导出文件为空，导出失败"
    exit 1
fi

# 检查文件头部
HEAD_LINE=$(zcat $EXPORT_FILE | head -1)
echo "      文件头: $HEAD_LINE"
echo ""

echo "========================================="
echo " 数据库导出完成!"
echo "========================================="
echo ""
echo "导出文件: $EXPORT_FILE"
echo "文件大小: $FILE_SIZE"
echo ""
echo "--- 传输到目标服务器 ---"
echo ""
echo "方法 1 — scp 传输:"
echo "  scp $EXPORT_FILE user@目标服务器IP:/tmp/"
echo ""
echo "方法 2 — rsync 传输（支持断点续传）:"
echo "  rsync -avP $EXPORT_FILE user@目标服务器IP:/tmp/"
echo ""
echo "--- 目标服务器操作 ---"
echo ""
echo "传输完成后，在目标服务器执行:"
echo "  bash 01b-database-import-prod.sh /tmp/$(basename $EXPORT_FILE)"
echo ""
echo "  或使用自定义数据库名:"
echo "  DB_NAME=cordys-crm-1.7.0 bash 01b-database-import-prod.sh /tmp/$(basename $EXPORT_FILE)"
