# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 全局约束

### 修改代码前必须先分析原因并提供方案

**每次修改代码前**，必须先：
1. **分析根因** — 解释为什么会出现这个问题（代码审查）
2. **提出方案** — 给出专业、全面的解决方案，说明每个修改点
3. **等待确认** — 用户确认后再执行修改
4. **验证结果** — 修改后运行测试 / 构建验证

不允许在不提供原因分析和方案的情况下直接修改代码。

## Project Overview

Cordys CRM is an open-source AI CRM system built by FIT2CLOUD. It covers full L2C (Lead-to-Cash) lifecycle: leads, intelligent assignment, customer/contact management, opportunities, contracts, payments, and order management.

- **Backend**: Java 21 + Spring Boot 3.5.14 + MyBatis + Apache Shiro + Flyway
- **Frontend**: Vue 3 + TypeScript + Vite (pnpm monorepo: `web` uses Naive-UI, `mobile` uses Vant-UI)
- **Infrastructure**: MySQL + Redis + Embedded MCP Server (Spring AI)
- **License**: FIT2CLOUD Open Source License (GPLv3 with extra restrictions — do NOT modify logos/copyright)

## Build & Run

### Prerequisites

- Java 21, Node.js 22 (via pnpm 10), Maven (wrapper `./mvnw` included)
- MySQL + Redis (or use embedded mode for dev — see `installer/conf/cordys-crm.properties`)

## Deployment Scripts

| Script | Purpose |
|--------|---------|
| `deploy_with_exist_db_redis.sh` | Full deployment using existing cordys-mysql + cordys-redis |
| `rebuild_backend.sh` | Compile backend (Maven inside cordys-backend container) |
| `start_backend.sh` | Start Spring Boot app (port 15173) |
| `start_frontend.sh` | Start Vite dev server (port 18083) |

### Services

- **Frontend**: http://localhost:18083
- **Backend API**: http://localhost:15173
- **Admin**: admin / CordysCRM
- **Database**: cordys-mysql:3306 / cordys-crm-1.7.0 (root/root)
- **Redis**: cordys-redis:6379
