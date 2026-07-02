#!/bin/bash
# 在服务器上运行: bash diagnose.sh > /tmp/diag.txt 2>&1
# 然后发 /tmp/diag.txt 给我

echo "========================================="
echo " CordysCRM CSRF 诊断"
echo " $(date)"
echo "========================================="

# === 1. 配置检查 ===
echo ""
echo "=== 1. cordys-crm.properties ==="
cat ~/cordys-1.7.0/conf/cordys-crm.properties

echo ""
echo "=== 2. 容器运行状态 ==="
docker ps --filter name=cordys-crm-1.7.0 --format '{{.Names}} {{.Status}}'

# === 2. 测试登录 API ===
echo ""
echo "=== 3. 获取 RSA 公钥（登录前需要） ==="
RSA_KEY=$(curl -s http://localhost:18084/key)
echo "RSA key: $RSA_KEY"

# === 3. 只看 AppListener 和 secret ===
echo ""
echo "=== 4. AppListener 启动状态 ==="
docker logs cordys-crm-1.7.0 2>&1 | grep -A 3 "开始初始化配置\|初始化RSA\|开始初始化\|AppListener" | tail -20

echo ""
echo "=== 5. 是否成功启动（最近一次） ==="
docker logs cordys-crm-1.7.0 2>&1 | grep "Tomcat started\|Application run failed\|Started Application" | tail -3

echo ""
echo "=== 6. CSRF secret 是否能读取到 ==="
docker exec cordys-crm-1.7.0 bash -c "
  find /app -name 'commons.properties' 2>/dev/null | head -3 | xargs grep 'cordys.secret' 2>/dev/null
  find /app -name 'application*.properties' 2>/dev/null | head -5 | xargs grep 'cordys.secret' 2>/dev/null
  find /opt/cordys -name '*.properties' 2>/dev/null | head -5 | xargs grep 'cordys.secret' 2>/dev/null
" 2>/dev/null || echo "无法执行"

echo ""
echo "=== 7. 实际测试登录并查看返回的 csrfToken ==="
# 先获取 key 里的 modulus 和 exponent
MODULUS=$(curl -s http://localhost:18084/key | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['modulus'])" 2>/dev/null)
EXPONENT=$(curl -s http://localhost:18084/key | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['exponent'])" 2>/dev/null)

if [ -z "$MODULUS" ]; then
    echo "RSA key 获取失败，改用 is-login 检查"
    # 检查 is-login 接口返回
    COOKIE_HEADER="Cookie: sessionId=test"
    LOGIN_CHECK=$(curl -s -H "$COOKIE_HEADER" http://localhost:18084/is-login)
    echo "is-login 返回: $LOGIN_CHECK"
else
    echo "RSA key 获取成功，但完整登录需要前端 RSA 加密，跳过。"
fi

echo ""
echo "=== 8. 检查 SessionUser 类的 secret 字段（通过 Spring Actuator 或日志） ==="
docker logs cordys-crm-1.7.0 2>&1 | grep -i "secret\|csrf\|CSRF\|SessionUser\|sessionUser\|开始初始化" | tail -20

echo ""
echo "=== 9. JAR 文件检查 ==="
echo "--- 挂载的 JAR ---"
ls -lh ~/cordys-1.7.0/*.jar
echo "--- 容器内 JAR ---"
docker exec cordys-crm-1.7.0 ls -lh /app/lib/ 2>/dev/null | grep -i jar

echo ""
echo "=== 10. 查看当前请求是否到达后端 ==="
# 直接测试一个需要 CSRF 的 API（会返回 401 或 CSRF 错误）
curl -s -w "\nHTTP_CODE:%{http_code}\n" -H "X-AUTH-TOKEN: test123" -H "CSRF-TOKEN: " http://localhost:18084/account/page -X POST -H "Content-Type: application/json" -d '{}' 2>/dev/null | tail -5

echo ""
echo "========================================="
echo " 诊断完成"
echo "========================================="
