#!/bin/bash
# ============================================================
# CordysCRM — 开发机构建发布包
# 用法: bash Deploy/build-release.sh
#
# 在开发机上运行，编译前后端，打包成发布包。
# 生产服务器只需下载解压 + 执行 quick-update.sh 即可完成更新。
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
RELEASE_DIR="/tmp/cordys-release"
TIMESTAMP=$(date +%Y%m%d-%H%M)
RELEASE_PKG="/tmp/cordys-release-${TIMESTAMP}.tar.gz"

echo "========================================="
echo " CordysCRM — 构建发布包"
echo "========================================="
echo ""

rm -rf "$RELEASE_DIR" && mkdir -p "$RELEASE_DIR"

# === 1. 编译后端 ===
echo "[1/3] 编译后端..."
cd "$PROJECT_DIR"
bash rebuild_backend.sh 2>&1 | tail -3

cp backend/crm/target/crm-main.jar "$RELEASE_DIR/"
cp backend/framework/target/framework-main.jar "$RELEASE_DIR/"
echo "  ✅ crm-main.jar + framework-main.jar"

# === 2. 编译前端 ===
echo "[2/3] 编译前端 Web..."
docker exec cordys-frontend bash -c "
  cd /workspace && pnpm run build --filter web 2>&1
" | tail -3

# 导出 dist
rm -rf "$RELEASE_DIR/web-dist" && mkdir -p "$RELEASE_DIR/web-dist"
docker cp cordys-frontend:/workspace/packages/web/dist/. "$RELEASE_DIR/web-dist/" 2>/dev/null
echo "  ✅ Web 前端"

# === 3. 打包 && 生成更新脚本 ===
echo "[3/3] 打包..."

cat > "$RELEASE_DIR/quick-update.sh" << 'SCRIPT'
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/cordys-1.7.0}"
APP_CONTAINER="${APP_CONTAINER:-cordys-crm-1.7.0}"

echo "========================================="
echo " CordysCRM — 快速更新"
echo "========================================="

# 更新后端 JAR（0- 前缀确保类路径优先加载）
echo "[1/2] 更新后端 JAR..."
cp "$SCRIPT_DIR/crm-main.jar" "$DEPLOY_DIR/0-crm-main.jar"
cp "$SCRIPT_DIR/framework-main.jar" "$DEPLOY_DIR/0-framework-main.jar"
echo "  ✅ JAR 已更新"

# 更新前端
echo "[2/2] 更新前端..."
docker cp "$SCRIPT_DIR/web-dist/." "$APP_CONTAINER:/app/static/"
echo "  ✅ 前端已更新"

# 重启应用
echo ""
echo "重启应用容器..."
docker restart "$APP_CONTAINER"

echo ""
echo "等待应用启动..."
for i in $(seq 1 20); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18084/ 2>/dev/null | grep -q "200\|302"; then
        echo "✅ 更新完成！"
        exit 0
    fi
    sleep 2
done
echo "⚠️  应用启动中，请稍后刷新页面"
SCRIPT
chmod +x "$RELEASE_DIR/quick-update.sh"

# 打包
tar czf "$RELEASE_PKG" -C "$RELEASE_DIR" .

echo ""
echo "========================================="
echo " 发布包: $RELEASE_PKG"
echo " 大小:   $(du -h "$RELEASE_PKG" | cut -f1)"
echo "========================================="
echo ""
echo "📋 部署到生产服务器:"
echo ""
echo "  scp $RELEASE_PKG basenton@服务器IP:~/"
echo ""
echo "  然后在服务器上执行:"
echo "  tar xzf ~/cordys-release-${TIMESTAMP}.tar.gz"
echo "  bash quick-update.sh"
echo ""
echo "  以后每次更新只需重复这两步！"
