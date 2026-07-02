-- ============================================================
-- CordysCRM 1.7.2 — 字典管理表
-- ============================================================

CREATE TABLE IF NOT EXISTS `sys_dict_category` (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `code` varchar(64) NOT NULL COMMENT '分类编码',
  `name` varchar(255) NOT NULL COMMENT '分类名称',
  `description` varchar(500) DEFAULT NULL COMMENT '分类描述',
  `enabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态',
  `pos` bigint NOT NULL DEFAULT '0' COMMENT '排序',
  `organization_id` varchar(32) NOT NULL COMMENT '组织id',
  `create_time` bigint NOT NULL COMMENT '创建时间',
  `update_time` bigint NOT NULL COMMENT '更新时间',
  `create_user` varchar(32) NOT NULL COMMENT '创建人',
  `update_user` varchar(32) NOT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code_org` (`code`,`organization_id`),
  KEY `idx_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `sys_dict_item` (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `category_id` varchar(32) NOT NULL COMMENT '分类ID',
  `value` varchar(255) NOT NULL COMMENT '字典项值',
  `label` varchar(255) NOT NULL COMMENT '字典项标签',
  `color` varchar(20) DEFAULT NULL COMMENT '颜色',
  `enabled` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态',
  `pos` bigint NOT NULL DEFAULT '0' COMMENT '排序',
  `create_time` bigint NOT NULL COMMENT '创建时间',
  `update_time` bigint NOT NULL COMMENT '更新时间',
  `create_user` varchar(32) NOT NULL COMMENT '创建人',
  `update_user` varchar(32) NOT NULL COMMENT '更新人',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
