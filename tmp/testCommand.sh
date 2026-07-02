#!/bin/bash
# 在服务器上运行: bash testCommand.sh
OUTPUT=/tmp/test-result.txt

{
echo "========================================="
echo " CordysCRM 生产环境诊断"
echo " $(date)"
echo "========================================="
echo ""

echo "=== 1. cordys-frontend 容器镜像 ==="
docker inspect cordys-frontend --format 'Image: {{.Config.Image}}' 2>/dev/null
docker inspect cordys-frontend --format 'Created: {{.Created}}' 2>/dev/null
echo ""

echo "=== 2. cordys-frontend 端口 ==="
docker port cordys-frontend 2>/dev/null
echo ""

echo "=== 3. cordys-crm-1.7.0 端口 ==="
docker port cordys-crm-1.7.0 2>/dev/null
echo ""

echo "=== 4. cordys-crm-1.7.0 网络信息 ==="
docker inspect cordys-crm-1.7.0 --format='
  端口绑定: {{range $p,$c := .NetworkSettings.Ports}}{{$p}} -> {{(index $c 0).HostPort}}{{"  "}}{{end}}
  网络: {{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}
  IP: {{.NetworkSettings.IPAddress}}' 2>/dev/null
echo ""

echo "=== 5. cordys-frontend 网络信息 ==="
docker inspect cordys-frontend --format='
  端口绑定: {{range $p,$c := .NetworkSettings.Ports}}{{$p}} -> {{(index $c 0).HostPort}}{{"  "}}{{end}}
  网络: {{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' 2>/dev/null
echo ""

echo "=== 6. cordys-frontend 挂载卷 ==="
docker inspect cordys-frontend --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{"\n"}}{{end}}' 2>/dev/null
echo ""

echo "=== 7. CSRF 配置 ==="
grep -r 'csrf\|CSRF\|samesite\|SameSite' ~/cordys-1.7.0/conf/ 2>/dev/null
echo ""

echo "=== 8. cordys-crm-1.7.0 启动命令 ==="
docker inspect cordys-crm-1.7.0 --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | grep -i 'csrf\|server\|port\|proxy\|host' | head -10
echo ""

echo "=== 9. 1Panel 反向代理配置 ==="
docker exec 1Panel-phpmyadmin-XHZM ls /etc/nginx/conf.d/ 2>/dev/null || echo "N/A"
find / -path "*/1panel/*" -name "*.conf" 2>/dev/null | xargs grep -l "cordys\|18084\|18083" 2>/dev/null | head -5
echo ""

echo "=== 10. 最近的 CSRF 错误（最后5条） ==="
docker logs cordys-crm-1.7.0 2>&1 | grep "CSRF token is empty" | tail -5
echo ""

echo "========================================="
echo " 诊断完成"
echo "========================================="
} > "$OUTPUT" 2>&1

cat "$OUTPUT"
echo ""
echo "结果已保存到: $OUTPUT"
