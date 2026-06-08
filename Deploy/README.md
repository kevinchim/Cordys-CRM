# Cordys CRM 1.7.0 中文部署指南

## 目录

- [1. 环境要求](#1-环境要求)
- [2. 快速部署（一键）](#2-快速部署一键)
- [3. 分步部署](#3-分步部署)
- [4. 配置说明](#4-配置说明)
- [5. 日常运维](#5-日常运维)
- [6. 故障排查](#6-故障排查)
- [7. 版本升级](#7-版本升级)

---

## 1. 环境要求

| 组件 | 要求 |
|------|------|
| 操作系统 | Ubuntu 22.04（推荐） |
| Docker | 20.10+ |
| 磁盘空间 | 10 GB+ |
| 内存 | 4 GB+（推荐 8 GB） |

### 与旧版共存

本部署方案与现有 1.6.x 版本完全隔离：

- **独立数据库**：`cordys-crm-1.7.0`（旧版 `cordys-crm` 不受影响）
- **独立容器**：所有容器名加 `-1.7.0` 后缀
- **独立端口**：默认前端 18083，后端 18084（旧版 15173 不变）
- **独立目录**：部署文件在 `~/cordys-1.7.0/`

---

## 2. 快速部署（一键）

```bash
# 1. 进入 Deploy 目录
cd Deploy

# 2. 查看并修改配置（按需）
vim .env

# 3. 一键部署
bash 01-database-migrate.sh && \
bash 02-backend-deploy.sh && \
bash 03-frontend-deploy.sh

# 4. 验证
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:18083/
```

部署完成后：
- 浏览器访问 `http://服务器IP:18083`
- 默认账号 `admin`，密码 `CordysCRM`

---

## 3. 分步部署

### 3.1 配置修改

编辑 `.env` 文件，按需修改以下配置：

```bash
# === 必须确认的配置 ===

# MySQL 容器名称（如果使用已有容器）
MYSQL_CONTAINER=cordys-mysql-1.7.0

# Redis 容器名称（如果使用已有容器）
REDIS_CONTAINER=cordys-redis-1.7.0

# === 可选修改 ===

# 前端访问端口
FRONTEND_PORT=18083

# 后端服务端口
BACKEND_PORT=18084

# 部署目录
DEPLOY_DIR=/home/kevin/cordys-1.7.0
```

### 3.2 数据库迁移

数据库迁移支持两种方式：

#### 方式 A：同机迁移（开发/测试环境）

旧版和新版在同一台机器上，直接从旧库迁移到新库：

```bash
bash 01-database-migrate.sh
```

**功能说明：**
1. 导出旧数据库 `cordys-crm` 完整备份
2. 创建新数据库 `cordys-crm-1.7.0`
3. 导入数据到新数据库
4. Flyway 会在应用启动时自动执行新版本表结构迁移

#### 方式 B：跨机器迁移（开发 → 生产）

分两步操作，先导出再导入：

**第一步：开发机器导出**

```bash
# 在开发机器上执行
bash 01a-database-export-dev.sh
# 输出: /tmp/cordys-crm-1.7.0-export-YYYYMMDD_HHMMSS.sql.gz
```

**传输到目标服务器：**

```bash
# scp 传输
scp /tmp/cordys-crm-1.7.0-export-*.sql.gz user@目标服务器IP:/tmp/

# 或 rsync（支持断点续传）
rsync -avP /tmp/cordys-crm-1.7.0-export-*.sql.gz user@目标服务器IP:/tmp/
```

**第二步：目标服务器导入**

```bash
# 在目标服务器上执行
bash 01b-database-import-prod.sh /tmp/cordys-crm-1.7.0-export-20260604_120000.sql.gz

# 如需自定义数据库名
DB_NAME=my-custom-db bash 01b-database-import-prod.sh /tmp/export.sql.gz
```

**功能说明：**
- 自动检测并创建 MySQL 容器（如果不存在）
- 目标数据库已存在时会提示确认（防误覆盖）
- 自动更新应用配置文件中的数据库名
- 导入后显示表清单和行数验证

**注意事项：**
- 旧数据库完全不受影响，仅做只读导出
- 备份文件保存在 `/tmp/` 目录
- 跨机器传输文件较大时建议使用 `rsync`
- 如果不需要迁移旧数据，可跳过此步，直接执行后端部署（Flyway 会创建空表结构）

### 3.3 后端部署

```bash
bash 02-backend-deploy.sh
```

**功能说明：**
1. 创建部署目录 `~/cordys-1.7.0/`
2. 使用 Maven 容器编译后端（自动创建 `cordys-backend-1.7.0-builder`）
3. 生成应用配置文件
4. 启动 Cordys CRM 1.7.0 应用容器

**编译说明：**
- 首次编译约 3-5 分钟（需下载 Maven 依赖）
- 后续编译约 1-2 分钟（使用缓存）
- 源码从 `SOURCE_DIR` 复制到编译容器

### 3.4 前端部署

```bash
bash 03-frontend-deploy.sh
```

**功能说明：**
1. 使用 Node.js 容器编译前端（自动创建 `cordys-frontend-1.7.0-builder`）
2. 编译 Vue 前端项目
3. 部署静态文件到应用容器
4. 重启应用使前端生效

**编译说明：**
- 首次编译约 3-5 分钟（需下载 npm 依赖）
- 编译失败常见原因：TypeScript 类型错误、依赖版本不兼容

---

## 4. 配置说明

### 4.1 端口配置

所有端口在 `.env` 文件中统一配置：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `FRONTEND_PORT` | 18083 | 浏览器访问端口 |
| `BACKEND_PORT` | 18084 | 后端服务端口 |
| `DB_PORT` | 3307 | MySQL 端口 |

### 4.2 数据库配置

数据库连接配置在 `$DEPLOY_DIR/conf/cordys-crm.properties`：

```properties
# MySQL
spring.datasource.url=jdbc:mysql://MYSQL_CONTAINER:3306/DB_NAME?...
spring.datasource.username=root
spring.datasource.password=root

# Redis
spring.data.redis.host=REDIS_CONTAINER
spring.data.redis.port=6379
```

### 4.3 容器命名

| 容器 | 命名格式 | 示例 |
|------|----------|------|
| 应用 | `cordys-crm-1.7.0` | `cordys-crm-1.7.0` |
| MySQL | `cordys-mysql-1.7.0` | `cordys-mysql-1.7.0` |
| Redis | `cordys-redis-1.7.0` | `cordys-redis-1.7.0` |
| 编译容器（临时） | `cordys-backend-1.7.0-builder` | 编译完成后可删除 |

---

## 5. 日常运维

### 5.1 启动/停止/重启

```bash
# 启动所有服务
bash start-services.sh start

# 停止所有服务
bash start-services.sh stop

# 重启所有服务
bash start-services.sh restart

# 查看服务状态
bash start-services.sh status
```

### 5.2 查看日志

```bash
# 应用日志（实时）
docker logs -f cordys-crm-1.7.0

# 应用日志（最近 100 行）
docker logs --tail 100 cordys-crm-1.7.0

# 错误日志
docker exec cordys-crm-1.7.0 tail -f /opt/cordys/logs/cordys-crm/error.log

# MySQL 日志
docker logs -f cordys-mysql-1.7.0
```

### 5.3 更新代码后重新部署

```bash
# 仅更新后端
bash 02-backend-deploy.sh

# 仅更新前端
bash 03-frontend-deploy.sh

# 全部重新部署
bash 02-backend-deploy.sh && bash 03-frontend-deploy.sh
```

### 5.4 备份数据库

```bash
docker exec cordys-mysql-1.7.0 mysqldump \
  -uroot -proot \
  --single-transaction \
  cordys-crm-1.7.0 \
  > ~/backup-$(date +%Y%m%d).sql
```

---

## 6. 故障排查

### 6.1 应用无法启动

```bash
# 1. 查看容器状态
docker ps -a --filter name=cordys-crm-1.7.0

# 2. 查看启动日志
docker logs cordys-crm-1.7.0 | tail -50

# 3. 常见原因
# - MySQL/Redis 未启动 → bash start-services.sh start
# - 端口冲突 → 修改 .env 中的端口
# - JAR 文件缺失 → 重新执行 02-backend-deploy.sh
```

### 6.2 数据库连接失败

```bash
# 检查 MySQL 容器是否运行
docker ps | grep mysql

# 检查网络连通性
docker exec cordys-crm-1.7.0 ping -c 1 cordys-mysql-1.7.0

# 检查数据库是否存在
docker exec cordys-mysql-1.7.0 mysql -uroot -proot -e "SHOW DATABASES;"
```

### 6.3 页面 404 或白屏

```bash
# 确认前端文件已部署
docker exec cordys-crm-1.7.0 ls /app/static/index.html

# 如果缺失，重新部署前端
bash 03-frontend-deploy.sh
```

### 6.4 编译失败

```bash
# 清理编译缓存后重试
docker rm -f cordys-backend-1.7.0-builder cordys-frontend-1.7.0-builder

# 重新执行部署脚本
bash 02-backend-deploy.sh
bash 03-frontend-deploy.sh
```

### 6.5 端口被占用

```bash
# 查看端口占用
lsof -i :18083

# 修改 .env 中的 FRONTEND_PORT / BACKEND_PORT
vim .env
```

---

## 7. 版本升级

### 7.1 从 1.6.x 升级到 1.7.0

本部署方案已包含完整的升级流程。数据库迁移脚本会自动处理数据迁移。

### 7.2 从 1.7.0 升级到更高版本

参考项目根目录下的 `Upgrade Guide.md` 和 `Upgrade Guide-Claude Code 指令.md`。

### 7.3 回滚

```bash
# 停止并删除 1.7.0 容器
docker stop cordys-crm-1.7.0
docker rm cordys-crm-1.7.0

# 旧版服务完全不受影响
# 旧版数据库 cordys-crm 保持不变
```

---

## 附录 A：文件清单

```
Deploy/
├── README.md                       # 本部署指南
├── .env                            # 端口和容器配置
├── 01-database-migrate.sh          # 数据库迁移（同机：旧库→新库）
├── 01a-database-export-dev.sh      # 数据库导出（开发机器 → SQL 文件）
├── 01b-database-import-prod.sh     # 数据库导入（目标服务器 ← SQL 文件）
├── 02-backend-deploy.sh            # 后端编译 + 部署脚本
├── 03-frontend-deploy.sh           # 前端编译 + 部署脚本
└── start-services.sh               # 日常启动/停止/状态脚本
```

## 附录 B：docker-compose 方式（可选）

如果需要使用 docker-compose 管理所有容器，可创建 `docker-compose.yml` 替代手动部署。

## 附录 C：生产环境安全建议

- [ ] 修改默认管理员密码
- [ ] 使用强密码替换 MySQL/Redis 默认密码
- [ ] 配置 HTTPS 反向代理（Nginx/Caddy）
- [ ] 限制数据库端口对外暴露（仅允许应用容器访问）
- [ ] 定期备份数据库
