-- set innodb lock wait timeout
SET SESSION innodb_lock_wait_timeout = 7200;

-- Welltrans CRM API push log table
CREATE TABLE sys_welltrans_push_log
(
    `id`              VARCHAR(32)  NOT NULL COMMENT 'id',
    `organization_id` VARCHAR(32)  NOT NULL COMMENT '组织id',
    `trigger_type`    VARCHAR(16)  NOT NULL COMMENT '触发类型: AUTO / MANUAL',
    `total_count`     INT          NOT NULL DEFAULT 0 COMMENT '推送总数',
    `success_count`   INT          NOT NULL DEFAULT 0 COMMENT '成功数',
    `fail_count`      INT          NOT NULL DEFAULT 0 COMMENT '失败数',
    `response_body`   TEXT         NULL COMMENT 'API响应内容',
    `error_message`   TEXT         NULL COMMENT '错误信息',
    `create_time`     BIGINT       NOT NULL COMMENT '创建时间',
    `update_time`     BIGINT       NOT NULL COMMENT '更新时间',
    `create_user`     VARCHAR(32)  NOT NULL COMMENT '创建人',
    `update_user`     VARCHAR(32)  NOT NULL COMMENT '更新人',
    PRIMARY KEY (id),
    INDEX idx_org_create_time (organization_id, create_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_general_ci;

-- set innodb lock wait timeout to default
SET SESSION innodb_lock_wait_timeout = DEFAULT;
