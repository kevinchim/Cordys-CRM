package cn.cordys.crm.system.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

@Data
public class WelltransPushConfigDTO {

    @Schema(description = "API地址")
    private String apiUrl;

    @Schema(description = "API Key")
    private String apiKey;

    @Schema(description = "自动回收时自动推送")
    private Boolean autoPushEnabled;

    @Schema(description = "手动回收时自动推送")
    private Boolean manualPushEnabled;
}
