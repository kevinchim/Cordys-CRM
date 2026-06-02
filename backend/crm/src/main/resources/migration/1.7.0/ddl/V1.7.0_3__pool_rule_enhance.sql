-- set innodb lock wait timeout
SET SESSION innodb_lock_wait_timeout = 7200;

-- Add daily view limit to customer pool pick rule
ALTER TABLE customer_pool_pick_rule
    ADD limit_daily_view BIT(1) NOT NULL DEFAULT 0 COMMENT '是否限制每日可看' after new_pick_interval;
ALTER TABLE customer_pool_pick_rule
    ADD daily_view_count INT DEFAULT 0 COMMENT '每日可看数量上限' after limit_daily_view;

-- Add daily view limit to clue pool pick rule
ALTER TABLE clue_pool_pick_rule
    ADD limit_daily_view BIT(1) NOT NULL DEFAULT 0 COMMENT '是否限制每日可看' after new_pick_interval;
ALTER TABLE clue_pool_pick_rule
    ADD daily_view_count INT DEFAULT 0 COMMENT '每日可看数量上限' after limit_daily_view;

-- Daily view record table
CREATE TABLE customer_pool_daily_view_record
(
    `id`              VARCHAR(32) NOT NULL COMMENT 'id',
    `pool_id`         VARCHAR(32) NOT NULL COMMENT '公海池ID',
    `customer_id`     VARCHAR(32) NOT NULL COMMENT '客户ID',
    `user_id`         VARCHAR(32) NOT NULL COMMENT '用户ID',
    `view_time`       BIGINT      NOT NULL COMMENT '查看时间',
    `create_time`     BIGINT      NOT NULL COMMENT '创建时间',
    `update_time`     BIGINT      NOT NULL COMMENT '更新时间',
    `create_user`     VARCHAR(32) NOT NULL COMMENT '创建人',
    `update_user`     VARCHAR(32) NOT NULL COMMENT '更新人',
    `organization_id` VARCHAR(32) NOT NULL COMMENT '组织id',
    PRIMARY KEY (id)
) COMMENT = '公海每日查看记录'
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8mb4
    COLLATE = utf8mb4_general_ci;

CREATE INDEX idx_pool_user_view_time ON customer_pool_daily_view_record (pool_id ASC, user_id ASC, view_time ASC);
CREATE INDEX idx_customer_id ON customer_pool_daily_view_record (customer_id ASC);

-- set innodb lock wait timeout to default
SET SESSION innodb_lock_wait_timeout = DEFAULT;
