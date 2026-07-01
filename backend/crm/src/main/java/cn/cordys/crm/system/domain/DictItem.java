package cn.cordys.crm.system.domain;

import cn.cordys.common.domain.BaseModel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Table;
import lombok.Data;

/**
 * 字典项表
 */
@Data
@Table(name = "sys_dict_item")
public class DictItem extends BaseModel {

    @Schema(description = "分类ID")
    private String categoryId;

    @Schema(description = "字典项值")
    private String value;

    @Schema(description = "字典项标签")
    private String label;

    @Schema(description = "颜色")
    private String color;

    @Schema(description = "是否启用")
    private Boolean enabled;

    @Schema(description = "排序")
    private Long pos;
}
