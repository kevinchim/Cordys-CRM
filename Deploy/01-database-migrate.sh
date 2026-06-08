#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 数据库迁移脚本
# 功能：从旧版数据库导出数据，创建新数据库并导入
# 用法：bash 01-database-migrate.sh
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

OLD_DB="cordys-crm"            # 旧版 1.6.x 数据库名
BACKUP_FILE="/tmp/cordys-crm-backup-$(date +%Y%m%d_%H%M%S).sql"

echo "========================================="
echo " Cordys CRM 1.7.0 — 数据库迁移"
echo "========================================="
echo "旧数据库: $OLD_DB"
echo "新数据库: $DB_NAME"
echo "备份文件: $BACKUP_FILE"
echo ""

# ---- Step 1: 导出旧数据库 ----
echo "[1/4] 导出旧数据库 $OLD_DB ..."
docker exec $MYSQL_CONTAINER mysqldump \
  -u$DB_USER -p$DB_PASSWORD \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --databases $OLD_DB \
  > $BACKUP_FILE

echo "      备份完成: $(du -h $BACKUP_FILE | cut -f1)"
echo ""

# ---- Step 2: 创建新数据库 ----
echo "[2/4] 创建新数据库 $DB_NAME ..."
docker exec $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD -e \
  "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

echo "      数据库 $DB_NAME 创建完成"
echo ""

# ---- Step 3: 导入到新数据库 ----
echo "[3/4] 导入数据到 $DB_NAME（可能需要几分钟）..."
# 替换 SQL 中的数据库名
sed "s/\`$OLD_DB\`/\`$DB_NAME\`/g" $BACKUP_FILE | \
  docker exec -i $MYSQL_CONTAINER mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME

echo "      数据导入完成"
echo ""

# ---- Step 4: Flyway 迁移 ----
echo "[4/4] Flyway 会在应用首次启动时自动执行新版本迁移"
echo "      无需手动操作"
echo ""

echo "========================================="
echo " 数据库迁移完成!"
echo " 备份文件: $BACKUP_FILE"
echo "========================================="
echo ""
echo "提示：如果 MySQL 容器尚未启动，请先执行 start-services.sh"
