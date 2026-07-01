package cn.cordys.crm.system.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class DictCategoryAddRequest {

    @NotBlank(message = "{dict_category_code_is_null}")
    @Size(max = 64, message = "{dict_category_code_too_long}")
    @Schema(description = "分类编码", requiredMode = Schema.RequiredMode.REQUIRED)
    private String code;

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
