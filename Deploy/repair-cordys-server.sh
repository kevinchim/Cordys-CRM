#!/bin/bash
# ============================================================
# CordysCRM — 修复 CSRF / 类加载问题
# 用法: bash Deploy/repair-cordys-server.sh
#
# 根因: 旧容器类路径 /app 优先于我们挂载的 JAR
#       导致老 AppListener 未设置 SessionUser.secret
#       修复: 加 0- 前缀让新 JAR 排在字母序最前 + 显式类路径
# ============================================================
set -e

APP_CONTAINER="cordys-crm-1.7.0"
DEPLOY_DIR="${DEPLOY_DIR:-$HOME/cordys-1.7.0}"
BASE_IMAGE="1panel/cordys-crm:v1.7.0"
NETWORK_NAME="cordyscrm_cordyscrm_default"

echo "========================================="
echo " CordysCRM — 修复部署"
echo "========================================="

# 准备带前缀的 JAR
echo "[1/3] 准备 JAR 文件..."
if [ ! -f "$DEPLOY_DIR/crm-main.jar" ]; then
    echo "❌ 未找到 crm-main.jar，请先运行 02-backend-deploy.sh"
    exit 1
fi
cp "$DEPLOY_DIR/crm-main.jar" "$DEPLOY_DIR/0-crm-main.jar"
cp "$DEPLOY_DIR/framework-main.jar" "$DEPLOY_DIR/0-framework-main.jar"
echo "  ✅ 0-crm-main.jar + 0-framework-main.jar"

# 停止并删除旧容器
echo "[2/3] 停止旧容器..."
docker stop $APP_CONTAINER 2>/dev/null || true
docker rm $APP_CONTAINER 2>/dev/null || true
echo "  ✅ 已清理"

# 启动新容器（修复类路径顺序）
echo "[3/3] 启动容器（修复类路径）..."
docker run -d \
  --name $APP_CONTAINER \
  --restart unless-stopped \
  --network $NETWORK_NAME \
  -p 18084:8081 \
  -e JAVA_CLASSPATH='/app/lib/0-crm-main.jar:/app/lib/0-framework-main.jar:/app:/app/lib/*' \
  -v $DEPLOY_DIR/conf:/opt/cordys/conf \
  -v $DEPLOY_DIR/logs:/opt/cordys/logs \
  -v $DEPLOY_DIR/data:/opt/cordys/data \
  -v $DEPLOY_DIR/0-crm-main.jar:/app/lib/0-crm-main.jar \
  -v $DEPLOY_DIR/0-framework-main.jar:/app/lib/0-framework-main.jar \
  $BASE_IMAGE

echo ""
echo "等待应用启动..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:18084/ 2>/dev/null | grep -q "200\|302"; then
        echo "✅ 部署成功！"
        echo ""
        echo "  现在用无痕模式登录: http://服务器IP:18084"
        echo "  账号: admin  密码: CordysCRM"
        exit 0
    fi
    sleep 2
done
echo "⚠️  应用启动中，请稍后重试"
