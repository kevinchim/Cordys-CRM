-- ============================================================
-- CordysCRM — 清空所有客户和联系人数据
-- 执行方式: mysql -uroot -proot cordys-crm-1.7.0 < tmp/clearCustomerContact.sql
-- ============================================================
SET SESSION innodb_lock_wait_timeout = 7200;

-- 1. 客户自定义字段 Blob 数据
DELETE FROM customer_field_blob;

-- 2. 客户自定义字段数据
DELETE FROM customer_field;

-- 3. 客户负责人历史
DELETE FROM customer_owner;

-- 4. 客户协作人
DELETE FROM customer_collaboration;

-- 5. 客户关系
DELETE FROM customer_relation;

-- 6. 联系人自定义字段 Blob 数据
DELETE FROM customer_contact_field_blob;

-- 7. 联系人自定义字段数据
DELETE FROM customer_contact_field;

-- 8. 联系人
DELETE FROM customer_contact;

-- 9. 客户
DELETE FROM customer;

-- 10. 公海池客户分配记录
DELETE FROM customer_pool_view_allocation;

-- 11. 公海池每日查看记录
DELETE FROM customer_pool_daily_view_record;

-- 验证清空结果
SELECT 'customer' as tbl, COUNT(*) as cnt FROM customer
UNION ALL
SELECT 'customer_contact', COUNT(*) FROM customer_contact
UNION ALL
SELECT 'customer_field', COUNT(*) FROM customer_field
UNION ALL
SELECT 'customer_field_blob', COUNT(*) FROM customer_field_blob
UNION ALL
SELECT 'customer_owner', COUNT(*) FROM customer_owner
UNION ALL
SELECT 'customer_collaboration', COUNT(*) FROM customer_collaboration
UNION ALL
SELECT 'customer_relation', COUNT(*) FROM customer_relation
UNION ALL
SELECT 'customer_contact_field', COUNT(*) FROM customer_contact_field
UNION ALL
SELECT 'customer_contact_field_blob', COUNT(*) FROM customer_contact_field_blob
UNION ALL
SELECT 'pool_view_allocation', COUNT(*) FROM customer_pool_view_allocation
UNION ALL
SELECT 'pool_daily_view_record', COUNT(*) FROM customer_pool_daily_view_record;

SET SESSION innodb_lock_wait_timeout = DEFAULT;
