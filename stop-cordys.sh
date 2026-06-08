#!/bin/bash
# ============================================
# Cordys CRM 1.7.0 — 停止脚本
# 用法：bash stop-cordys.sh
# ============================================

echo "========================================="
echo " Cordys CRM 1.7.0 — 停止服务"
echo "========================================="

echo "[1/3] 停止应用..."
docker stop cordys-crm-1.7.0 2>/dev/null && echo "      应用已停止" || echo "      应用未在运行"

echo "[2/3] 停止 Redis..."
docker stop cordys-redis 2>/dev/null && echo "      Redis 已停止" || echo "      Redis 未在运行"

echo "[3/3] 停止 MySQL..."
docker stop cordys-mysql 2>/dev/null && echo "      MySQL 已停止" || echo "      MySQL 未在运行"

echo ""
echo "已全部停止"
