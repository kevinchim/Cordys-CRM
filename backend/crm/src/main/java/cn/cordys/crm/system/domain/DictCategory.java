package cn.cordys.crm.system.domain;

import cn.cordys.common.domain.BaseModel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Table;
import lombok.Data;

/**
 * 字典分类表
 */
@Data
@Table(name = "sys_dict_category")
public class DictCategory extends BaseModel {

    @Schema(description = "分类编码")
    private String code;

    @Schema(description = "分类名称")
    private String name;

    @Schema(description = "描述")
    private String description;

    @Schema(description = "是否启用")
    private Boolean enabled;

    @Schema(description = "排序")
    private Long pos;

    @Schema(description = "组织ID")
    private String organizationId;
}
