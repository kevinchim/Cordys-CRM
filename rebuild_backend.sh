#!/bin/bash
# ============================================================
# CordysCRM - 重新编译后端
# 使用 cordys-backend 容器 (maven:3.9-eclipse-temurin-21)
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTAINER="cordys-backend"
SRC_DIR="/tmp/CordysCRM-1.7.2"

echo "=============================================="
echo "  CordysCRM - 后端重新编译"
echo "=============================================="
echo ""

# 1. 检查容器
echo "[1/4] 检查构建容器 ${CONTAINER}..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "  ❌ 容器 ${CONTAINER} 未运行！请先启动 cordys-backend 容器。"
    exit 1
fi
echo "  ✅ 容器 ${CONTAINER} 运行中"

# 2. 同步源码
echo "[2/4] 同步项目源码到容器..."
docker cp "${SCRIPT_DIR}/backend" ${CONTAINER}:${SRC_DIR}/backend 2>/dev/null || true
docker cp "${SCRIPT_DIR}/pom.xml" ${CONTAINER}:${SRC_DIR}/pom.xml
docker cp "${SCRIPT_DIR}/mvnw" ${CONTAINER}:${SRC_DIR}/mvnw
docker cp "${SCRIPT_DIR}/.mvn" ${CONTAINER}:${SRC_DIR}/.mvn
echo "  ✅ 源码同步完成"

# 3. 编译 framework 模块
echo "[3/4] 编译 framework 模块..."
docker exec ${CONTAINER} bash -c "
  cd ${SRC_DIR} && \
  ./mvnw install -N -DskipTests -q 2>&1 && \
  ./mvnw install -pl framework -DskipTests -q --file backend/pom.xml 2>&1
"
echo "  ✅ framework 编译完成"

# 4. 编译 crm 模块 (主应用)
echo "[4/4] 编译 crm 模块 (主应用)..."
docker exec ${CONTAINER} bash -c "
  cd ${SRC_DIR} && \
  ./mvnw install -pl crm -DskipTests -DskipAntRunForJenkins -q --file backend/pom.xml 2>&1
"

# 验证产物
JAR_SIZE=$(docker exec ${CONTAINER} ls -lh ${SRC_DIR}/backend/crm/target/crm-main.jar 2>/dev/null | awk '{print $5}')
echo "  ✅ crm 编译完成 (crm-main.jar: ${JAR_SIZE})"

echo ""
echo "=============================================="
echo "  🎉 后端编译成功!"
echo "=============================================="
