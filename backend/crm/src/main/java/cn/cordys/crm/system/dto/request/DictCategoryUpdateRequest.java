package cn.cordys.crm.system.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class DictCategoryUpdateRequest {

    @NotBlank(message = "{dict_category_id_is_null}")
    @Schema(description = "分类ID", requiredMode = Schema.RequiredMode.REQUIRED)
    private String id;

    @NotBlank(message = "{dict_category_name_is_null}")
    @Size(max = 255, message = "{dict_category_name_too_long}")
    @Schema(description = "分类名称", requiredMode = Schema.RequiredMode.REQUIRED)
    private String name;

    @Size(max = 500)
    @Schema(description = "描述")
    private String description;

    @Schema(description = "排序")
    private Long pos;

    @Schema(description = "是否启用")
    private Boolean enabled;
}
