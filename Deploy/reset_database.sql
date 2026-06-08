-- ============================================
-- Cordys CRM 1.7.0 — 数据库清空脚本
-- 功能：清空所有业务数据，仅保留 admin 用户和系统配置
-- 用法：docker exec -i cordys-mysql mysql -uroot -proot cordys-crm-1.7.0 < reset_database.sql
-- ============================================

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 1. 清空业务数据表
-- ============================================

-- 客户模块
TRUNCATE TABLE customer;
TRUNCATE TABLE customer_contact;
TRUNCATE TABLE customer_contact_field;
TRUNCATE TABLE customer_contact_field_blob;
TRUNCATE TABLE customer_field;
TRUNCATE TABLE customer_field_blob;
TRUNCATE TABLE customer_owner;
TRUNCATE TABLE customer_capacity;
TRUNCATE TABLE customer_collaboration;
TRUNCATE TABLE customer_relation;
TRUNCATE TABLE customer_pool_daily_view_record;
TRUNCATE TABLE customer_pool_view_allocation;

-- 线索模块
TRUNCATE TABLE clue;
TRUNCATE TABLE clue_field;
TRUNCATE TABLE clue_field_blob;
TRUNCATE TABLE clue_owner;
TRUNCATE TABLE clue_capacity;

-- 商机模块
TRUNCATE TABLE opportunity;
TRUNCATE TABLE opportunity_field;
TRUNCATE TABLE opportunity_field_blob;
TRUNCATE TABLE opportunity_quotation;
TRUNCATE TABLE opportunity_quotation_field;
TRUNCATE TABLE opportunity_quotation_field_blob;
TRUNCATE TABLE opportunity_quotation_snapshot;

-- 合同模块
TRUNCATE TABLE contract;
TRUNCATE TABLE contract_field;
TRUNCATE TABLE contract_field_blob;
TRUNCATE TABLE contract_snapshot;
TRUNCATE TABLE contract_invoice;
TRUNCATE TABLE contract_invoice_field;
TRUNCATE TABLE contract_invoice_field_blob;
TRUNCATE TABLE contract_invoice_snapshot;
TRUNCATE TABLE contract_payment_plan;
TRUNCATE TABLE contract_payment_plan_field;
TRUNCATE TABLE contract_payment_plan_field_blob;
TRUNCATE TABLE contract_payment_record;
TRUNCATE TABLE contract_payment_record_field;
TRUNCATE TABLE contract_payment_record_field_blob;

-- 订单模块
TRUNCATE TABLE sales_order;
TRUNCATE TABLE sales_order_field;
TRUNCATE TABLE sales_order_field_blob;
TRUNCATE TABLE sales_order_snapshot;

-- 产品模块
TRUNCATE TABLE product;
TRUNCATE TABLE product_field;
TRUNCATE TABLE product_field_blob;
TRUNCATE TABLE product_price;
TRUNCATE TABLE product_price_field;
TRUNCATE TABLE product_price_field_blob;

-- 开票抬头
TRUNCATE TABLE business_title;
TRUNCATE TABLE business_title_config;

-- 跟进计划/记录
TRUNCATE TABLE follow_up_plan;
TRUNCATE TABLE follow_up_plan_field;
TRUNCATE TABLE follow_up_plan_field_blob;
TRUNCATE TABLE follow_up_record;
TRUNCATE TABLE follow_up_record_field;
TRUNCATE TABLE follow_up_record_field_blob;

-- ============================================
-- 2. 清空审批数据
-- ============================================
TRUNCATE TABLE approval_instance;
TRUNCATE TABLE approval_instance_attachment;
TRUNCATE TABLE approval_record;
TRUNCATE TABLE approval_return_back_record;
TRUNCATE TABLE approval_task;
TRUNCATE TABLE approval_add_sign_task;

-- ============================================
-- 3. 清空操作日志和通知
-- ============================================
TRUNCATE TABLE sys_operation_log;
TRUNCATE TABLE sys_operation_log_blob;
TRUNCATE TABLE sys_login_log;
TRUNCATE TABLE sys_notification;
TRUNCATE TABLE export_task;
TRUNCATE TABLE sys_welltrans_push_log;

-- ============================================
-- 4. 清空附件
-- ============================================
TRUNCATE TABLE sys_attachment;

-- ============================================
-- 5. 删除非 admin 用户及相关数据
-- ============================================
DELETE FROM sys_user_extend WHERE id != 'admin';
DELETE FROM sys_user_role WHERE user_id != 'admin';
DELETE FROM sys_user_view_condition WHERE sys_user_view_id IN (SELECT id FROM sys_user_view WHERE user_id != 'admin');
DELETE FROM sys_user_view WHERE user_id != 'admin';
DELETE FROM sys_user_search_config WHERE user_id != 'admin';
DELETE FROM sys_organization_user WHERE user_id != 'admin';
DELETE FROM user_key WHERE create_user != 'admin';
DELETE FROM sys_user WHERE id != 'admin';

-- ============================================
-- 6. 清空仪表板和智能体收藏（个人数据）
-- ============================================
TRUNCATE TABLE dashboard_collection;
TRUNCATE TABLE agent_collection;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 验证
-- ============================================
SELECT 'customer' AS `table`, COUNT(*) AS `rows` FROM customer
UNION ALL SELECT 'customer_contact', COUNT(*) FROM customer_contact
UNION ALL SELECT 'clue', COUNT(*) FROM clue
UNION ALL SELECT 'opportunity', COUNT(*) FROM opportunity
UNION ALL SELECT 'contract', COUNT(*) FROM contract
UNION ALL SELECT 'sales_order', COUNT(*) FROM sales_order
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'sys_user', COUNT(*) FROM sys_user
UNION ALL SELECT 'sys_operation_log', COUNT(*) FROM sys_operation_log;
