-- set innodb lock wait timeout
SET SESSION innodb_lock_wait_timeout = 7200;

-- Add monthly view limit to clue pool pick rule
ALTER TABLE clue_pool_pick_rule
    ADD limit_monthly_view BIT(1) NOT NULL DEFAULT 0 COMMENT '是否限制每月可看' after daily_view_count;
ALTER TABLE clue_pool_pick_rule
    ADD monthly_view_count INT DEFAULT 0 COMMENT '每月可看数量上限' after limit_monthly_view;

-- Add monthly pickup limit to clue pool pick rule
ALTER TABLE clue_pool_pick_rule
    ADD limit_monthly_pick BIT(1) NOT NULL DEFAULT 0 COMMENT '是否限制每月领取' after monthly_view_count;
ALTER TABLE clue_pool_pick_rule
    ADD monthly_pick_count INT DEFAULT 0 COMMENT '每月领取数量上限' after limit_monthly_pick;

-- set innodb lock wait timeout to default
SET SESSION innodb_lock_wait_timeout = DEFAULT;
