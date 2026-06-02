-- set innodb lock wait timeout
SET SESSION innodb_lock_wait_timeout = 7200;

-- Customer pool view allocation table (daily/monthly customer allocation for view limits)
CREATE TABLE customer_pool_view_allocation
(
    `id`              VARCHAR(32)  NOT NULL COMMENT 'id',
    `pool_id`         VARCHAR(32)  NOT NULL COMMENT '公海池ID',
    `user_id`         VARCHAR(32)  NOT NULL COMMENT '用户ID',
    `customer_id`     VARCHAR(32)  NOT NULL COMMENT '客户ID',
    `period_type`     VARCHAR(16)  NOT NULL COMMENT '周期类型: DAILY / MONTHLY',
    `period_key`      VARCHAR(8)   NOT NULL COMMENT '周期key: yyyyMMdd / yyyyMM',
    `create_time`     BIGINT       NOT NULL COMMENT '创建时间',
    `update_time`     BIGINT       NOT NULL COMMENT '更新时间',
    `create_user`     VARCHAR(32)  NOT NULL COMMENT '创建人',
    `update_user`     VARCHAR(32)  NOT NULL COMMENT '更新人',
    `organization_id` VARCHAR(32)  NOT NULL COMMENT '组织id',
    PRIMARY KEY (id),
    INDEX idx_pool_user_period (pool_id, user_id, period_type, period_key),
    INDEX idx_customer_id (customer_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- set innodb lock wait timeout to default
SET SESSION innodb_lock_wait_timeout = DEFAULT;
