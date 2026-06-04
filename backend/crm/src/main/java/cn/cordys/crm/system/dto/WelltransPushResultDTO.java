package cn.cordys.crm.system.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class WelltransPushResultDTO {

    @Schema(description = "是否成功")
    private Boolean success;

    @Schema(description = "推送总数")
    private Integer totalCount;

    @Schema(description = "成功数")
    private Integer successCount;

    @Schema(description = "失败数")
    private Integer failCount;

    @Schema(description = "API响应消息")
    private String message;

    @Schema(description = "警告信息")
    private List<String> warnings;

    @Schema(description = "错误信息")
    private String errorMessage;
}
