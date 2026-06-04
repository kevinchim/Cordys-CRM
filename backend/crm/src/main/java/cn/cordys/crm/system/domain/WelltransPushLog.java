package cn.cordys.crm.system.domain;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Table(name = "sys_welltrans_push_log")
public class WelltransPushLog {

    @Id
    @Schema(description = "id")
    private String id;

    @Schema(description = "组织id")
    private String organizationId;

    @Schema(description = "触发类型: AUTO / MANUAL")
    private String triggerType;

    @Schema(description = "推送总数")
    private Integer totalCount;

    @Schema(description = "成功数")
    private Integer successCount;

    @Schema(description = "失败数")
    private Integer failCount;

    @Schema(description = "API响应内容")
    private String responseBody;

    @Schema(description = "错误信息")
    private String errorMessage;

    @Schema(description = "创建时间")
    private Long createTime;

    @Schema(description = "更新时间")
    private Long updateTime;

    @Schema(description = "创建人")
    private String createUser;

    @Schema(description = "更新人")
    private String updateUser;
}
