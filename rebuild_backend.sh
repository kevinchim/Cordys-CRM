#!/bin/bash
# ============================================================
# CordysCRM - 重新编译后端
# 使用 cordys-backend 容器 (maven:3.9-eclipse-temurin-21)
# 项目目录已挂载到容器内 /workspace
# ============================================================
set -e

CONTAINER="cordys-backend"
SRC_DIR="/workspace"

echo "=============================================="
echo "  CordysCRM - 后端重新编译"
echo "=============================================="
echo ""

# 1. 检查容器
echo "[1/5] 检查构建容器 ${CONTAINER}..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "  ❌ 容器 ${CONTAINER} 未运行！"
    exit 1
fi
echo "  ✅ 容器 ${CONTAINER} 运行中（项目目录已挂载到 /workspace）"

# 2. 编译 parent POM (root + backend)
echo "[2/4] 编译 parent POM..."
docker exec ${CONTAINER} bash -c "
  export MAVEN_OPTS='-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true' && \
  cd ${SRC_DIR} && \
  ./mvnw install -N -DskipTests -q 2>&1 && \
  ./mvnw install -N -DskipTests -q --file backend/pom.xml 2>&1
"
echo "  ✅ parent POM 安装完成"

# 3. 编译所有模块 (framework → crm → app)
echo "[3/4] 编译 framework → crm → app 模块..."
docker exec ${CONTAINER} bash -c "
  export MAVEN_OPTS='-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true' && \
  cd ${SRC_DIR} && ./mvnw install -pl framework,crm,app -DskipTests -DskipAntRunForJenkins -q --file backend/pom.xml 2>&1
"
echo "  ✅ 所有模块编译完成"

# 验证产物
JAR_FILE=$(docker exec ${CONTAINER} bash -c "ls ${SRC_DIR}/backend/app/target/*.jar 2>/dev/null | head -1")
JAR_SIZE=$(docker exec ${CONTAINER} ls -lh "${JAR_FILE}" 2>/dev/null | awk '{print $5}')
echo "  ✅ app 编译完成 (${JAR_FILE##*/}: ${JAR_SIZE})"

echo ""
echo "=============================================="
echo "  🎉 后端编译成功!"
echo "=============================================="
