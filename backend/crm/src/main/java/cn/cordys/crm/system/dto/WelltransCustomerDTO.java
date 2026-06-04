package cn.cordys.crm.system.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class WelltransCustomerDTO {

    @Schema(description = "邮箱或电话")
    private String email;

    @Schema(description = "负责销售人员")
    private String sales;

    @Schema(description = "联系方式类型: 0=电话, 1=邮箱")
    private Integer type;

    @Schema(description = "是否已合作: 0=未合作, 1=已合作")
    private Integer iscooperated;

    @Schema(description = "是否完整邮箱地址: 0=否, 1=是")
    private Integer isfullemailaddress;

    @Schema(description = "创建时间")
    private String createDate;
}
