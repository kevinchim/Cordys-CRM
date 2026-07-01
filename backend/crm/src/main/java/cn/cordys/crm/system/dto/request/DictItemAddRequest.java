package cn.cordys.crm.system.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class DictItemAddRequest {

    @NotBlank(message = "{dict_item_category_id_is_null}")
    @Schema(description = "分类ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private String categoryId;

    @NotBlank(message = "{dict_item_value_is_null}")
    @Size(max = 255)
    @Schema(description = "字典项值", requiredMode = Schema.RequiredMode.REQUIRED)
    private String value;

    @NotBlank(message = "{dict_item_label_is_null}")
    @Size(max = 255)
    @Schema(description = "字典项标签", requiredMode = Schema.RequiredMode.REQUIRED)
    private String label;

    @Size(max = 20)
    @Schema(description = "颜色")
    private String color;

    @Schema(description = "排序")
    private Long pos;

    @Schema(description = "是否启用")
    private Boolean enabled;
}
