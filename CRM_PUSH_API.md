# CRM 客户数据推送对接文档

## 1. 功能概述

外部 CRM 系统通过 HTTP API 批量推送客户数据至本系统临时表 `push_emails`。超级管理员登录后在 dashboard 右上角收到提醒，进入预览页确认后，可手动将全部数据同步至正式 `emails` 客户表。

**重要约束：**

- 每次 CRM 新推送会先清空 `push_emails` 旧数据，再写入新数据
- 系统不会自动同步至 `emails` 主表，必须超级管理员手动确认
- 非超级管理员无 API 管理权限、无页面入口、无提醒

---

## 2. 部署前置步骤

### 2.1 创建临时表

在 MySQL 中执行（需已存在 `emails` 表）：

```sql
CREATE TABLE IF NOT EXISTS push_emails LIKE emails;
```

或执行项目脚本：`sql/create_push_emails.sql`

> `push_emails` 表结构与 `emails` 表 **100% 一致**（字段、类型、索引均通过 `LIKE emails` 复制）。

### 2.2 配置 API Key

编辑 `includes/crm_push_config.php`，修改：

```php
define('CRM_PUSH_API_KEY', 'your_strong_random_key_here');
```

CRM 调用接口时必须携带此 Key。

---

## 3. 对外接收 API

### 3.1 接口地址

```
POST https://welltrans-logistics.com/crm/api/crm_push_emails.php
```

示例（本地）：

```
POST http://localhost/crm/api/crm_push_emails.php
```

### 3.2 请求方式

- **Method**: `POST`
- **Content-Type**: `application/json; charset=utf-8`

### 3.3 鉴权方式（二选一）

**方式 A：请求头（推荐）**

```
X-CRM-Api-Key: your_strong_random_key_here
```

**方式 B：JSON Body**

```json
{
  "api_key": "your_strong_random_key_here",
  "customers": [ ... ]
}
```

---

## 4. 入参结构

### 4.1 标准格式（推荐）

```json
{
  "customers": [
    {
      "email": "client@example.com",
      "sales": "张三",
      "type": 1,
      "iscooperated": 0,
      "isfullemailaddress": 1,
      "create_date": "2026-06-02 10:30:00"
    },
    {
      "email": "13800138000",
      "sales": "李四",
      "type": 0,
      "iscooperated": 0,
      "isfullemailaddress": 0
    }
  ]
}
```

### 4.2 兼容格式

**单条对象：**

```json
{
  "email": "client@example.com",
  "sales": "张三",
  "type": 1
}
```

**直接数组：**

```json
[
  { "email": "a@example.com", "sales": "张三" },
  { "email": "b@example.com", "sales": "李四" }
]
```

### 4.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | 是 | 客户邮箱或电话号码（存入 emails.email 字段） |
| sales | string | 是 | 负责销售人员姓名 |
| type | int | 否 | 联系方式类型，见下方枚举；不传时自动推断 |
| iscooperated | int | 否 | 是否已合作，见下方枚举；不传时按 sales 推断 |
| isfullemailaddress | int | 否 | 是否完整邮箱地址，见下方枚举；不传时自动推断 |
| create_date | string | 否 | 创建时间，格式 `Y-m-d H:i:s`；不传则使用接收时间 |

---

## 5. 字段枚举释义（CRM 必看）

### 5.1 type — 联系方式类型

| 值 | 含义 |
|----|------|
| 0 | 电话号码（数字号码） |
| 1 | 邮箱地址 |

**自动推断规则（未传 type 时）：**

- `email` 字段为纯数字 → `type = 0`
- 否则 → `type = 1`

### 5.2 isfullemailaddress — 是否完整邮箱地址

| 值 | 含义 |
|----|------|
| 0 | 非完整邮箱（格式无效或非邮箱类型） |
| 1 | 完整有效邮箱地址 |

**自动推断规则（未传时）：**

- `type = 1` 且 email 通过标准邮箱格式校验 → `1`
- 否则 → `0`

### 5.3 iscooperated — 是否已合作

| 值 | 含义 |
|----|------|
| 0 | 未合作 |
| 1 | 已合作 |

**自动推断规则（未传时）：**

- `sales` 小写等于 `kevin` → `1`
- 否则 → `0`

---

## 6. 出参结构

### 6.1 成功响应

HTTP `200`

```json
{
  "success": true,
  "message": "CRM 客户数据接收成功",
  "data": {
    "received": 100,
    "inserted": 98,
    "invalid": 2,
    "deduplicated": 0,
    "warnings": [
      "第 3 条: email 不能为空"
    ]
  }
}
```

| 字段 | 说明 |
|------|------|
| received | CRM 推送总条数 |
| inserted | 实际写入 push_emails 条数 |
| invalid | 校验失败条数 |
| deduplicated | 按 email 去重合并条数 |
| warnings | 无效数据明细 |

### 6.2 失败响应

**401 鉴权失败**

```json
{ "success": false, "message": "API Key 无效或未提供" }
```

**400 参数错误**

```json
{ "success": false, "message": "customers 数组不能为空" }
```

**500 服务器错误**

```json
{ "success": false, "message": "写入 push_emails 失败: ..." }
```

---

## 7. 管理端功能（超级管理员）

### 7.1 权限

- 仅 `role > 1`（超级管理员）可见
- 普通管理员/普通用户：无提醒、无菜单、无 API 权限

### 7.2 右上角提醒

- `push_emails` 有数据时：dashboard 右上角显示「新 CRM 数据待接收（N）」
- 表为空时：提醒自动消失
- 点击提醒：打开 `push_emails_preview.php` 预览页

### 7.3 预览页操作

| 操作 | 行为 |
|------|------|
| 全部更新同步 | 清空 `emails_from_crm` 表 → **清洗** `push_emails` 数据后写入 `emails_from_crm` → 清空 `push_emails` → 提醒消失（**不影响原 `emails` 表**） |
| 取消不同步 | 不修改 `emails_from_crm` 表，临时数据保留，提醒继续显示 |

### 7.4 同步至 emails_from_crm 时的数据清洗规则

> `push_emails` 临时表保留 CRM 原始推送数据；仅在「全部更新同步」写入 `emails_from_crm` 表前执行清洗。

| 数据类型 | 清洗规则 | isfullemailaddress |
|----------|----------|-------------------|
| 公共邮箱 | 保留完整邮箱地址（如 `john@gmail.com`） | 1 |
| 企业邮箱 | 去掉前缀，仅存 `@域名`（如 `john@basenton.com` → `@basenton.com`） | 0 |
| 电话号码 | 仅保留数字，去除符号和空格（如 `+86 138-0013-8000` → `8613800138000`） | 0 |

**公共邮箱判定**：邮箱域名匹配 `includes/public_email_patterns.php` 中的通配规则即为公共邮箱，否则视为企业邮箱。

公共邮箱规则示例：

- `*@gmail.*` → 匹配 `gmail.com`、`gmail.co.uk` 等
- `*@163.*` → 匹配 `163.com`、`163.net` 等
- `*@yeah.net` → 精确匹配 `yeah.net`

完整公共邮箱列表见配置文件 `includes/public_email_patterns.php`（共 57 条，支持 `*` 通配符）。

清洗后按 `email` 字段去重（相同清洗结果保留最后一条）。

### 7.5 邮箱验证过滤集成

同步至 `emails_from_crm` 的数据会参与以下功能的客户过滤（与原 `emails` 表规则完全一致）：

- `sortcustomer.php` → `sortcustomer_action.php`（邮箱验证）
- `kevin_filter_invalid.php` → `kevin_filter_invalid_action.php`（过滤无效邮箱）

即：过滤时同时查询 `emails` 与 `emails_from_crm`，原有 invalid_emails、销售排除、域名匹配等逻辑不变。

---

## 8. 内部管理 API（需登录 + 超级管理员）

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/push_emails_status.php` | GET | 查询是否有待处理数据 |
| `/api/push_emails_list.php` | GET | 分页预览 push_emails 数据 |
| `/api/push_emails_action.php` | POST | 同步/取消操作 |

### push_emails_action.php 入参

```json
{ "action": "sync_all" }
```

或

```json
{ "action": "cancel" }
```

---

## 9. 文件变更明细

| 文件 | 类型 | 说明 |
|------|------|------|
| `sql/create_push_emails.sql` | 新增 | push_emails 建表脚本 |
| `sql/create_emails_from_crm.sql` | 新增 | emails_from_crm 建表脚本 |
| `includes/crm_push_config.php` | 新增 | API Key 配置 |
| `includes/push_emails_helper.php` | 新增 | 表结构/校验/同步公共逻辑 |
| `includes/public_email_patterns.php` | 新增 | 公共邮箱域名通配规则（可维护配置） |
| `includes/email_storage_cleaner.php` | 新增 | 同步至 emails_from_crm 前的数据清洗逻辑 |
| `api/crm_push_emails.php` | 新增 | CRM 对外推送接收 API |
| `api/push_emails_status.php` | 新增 | 待处理状态查询 |
| `api/push_emails_list.php` | 新增 | 预览列表 API |
| `api/push_emails_action.php` | 新增 | 同步/取消 API |
| `push_emails_preview.php` | 新增 | 超级管理员预览页 |
| `dashboard.php` | 修改 | 右上角提醒 + 系统管理菜单入口 |
| `sortcustomer_action.php` | 修改 | 过滤时合并 emails_from_crm |
| `kevin_filter_invalid_action.php` | 修改 | 过滤时合并 emails_from_crm |

---

## 10. CRM 调用示例

### cURL

```bash
curl -X POST "https://welltrans-logistics.com/crm/api/crm_push_emails.php" \
  -H "Content-Type: application/json" \
  -H "X-CRM-Api-Key: your_strong_random_key_here" \
  -d '{
    "customers": [
      {
        "email": "test@example.com",
        "sales": "王五",
        "type": 1,
        "iscooperated": 0,
        "isfullemailaddress": 1
      }
    ]
  }'
```

### PHP

```php
$payload = [
    'customers' => [
        [
            'email' => 'test@example.com',
            'sales' => '王五',
            'type' => 1,
            'iscooperated' => 0,
            'isfullemailaddress' => 1,
        ],
    ],
];

$ch = curl_init('https://welltrans-logistics.com/crm/api/crm_push_emails.php');
curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_HTTPHEADER => [
        'Content-Type: application/json',
        'X-CRM-Api-Key: your_strong_random_key_here',
    ],
    CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
    CURLOPT_RETURNTRANSFER => true,
]);
$response = curl_exec($ch);
curl_close($ch);
```

---

## 11. 业务闭环说明

1. CRM 调用 `crm_push_emails.php` → 清空 `push_emails` → 写入新数据
2. 超级管理员登录 → 右上角出现提醒
3. 进入预览页查看数据
4. 选择「全部更新同步」→ `emails_from_crm` 被覆盖（`emails` 表不变）→ `push_emails` 清空 → 提醒消失
5. 或选择「取消不同步」→ `emails_from_crm` 不变 → 临时数据保留 → 提醒继续

---

## 12. 注意事项

- 生产环境务必修改默认 API Key
- 「全部更新同步」会 **清空并覆盖** 现有 `emails_from_crm` 表全部数据（原 `emails` 表不受影响），操作前请确认
- 同一批推送中重复 email 会自动去重（后者覆盖前者）
- 部分无效数据会被跳过并记录在 `warnings` 中，不影响有效数据写入
