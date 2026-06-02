package cn.cordys.crm.customer.domain;

import cn.cordys.common.domain.BaseModel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Table(name = "customer_pool_daily_view_record")
public class CustomerPoolDailyViewRecord extends BaseModel {

    @Schema(description = "公海池ID")
    private String poolId;

    @Schema(description = "客户ID")
    private String customerId;

    @Schema(description = "用户ID")
    private String userId;

    @Schema(description = "查看时间")
    private Long viewTime;

    @Schema(description = "组织id")
    private String organizationId;
}
