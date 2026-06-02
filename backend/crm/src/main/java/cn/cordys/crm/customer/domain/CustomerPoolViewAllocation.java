package cn.cordys.crm.customer.domain;

import cn.cordys.common.domain.BaseModel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Table(name = "customer_pool_view_allocation")
public class CustomerPoolViewAllocation extends BaseModel {

    @Schema(description = "公海池ID")
    private String poolId;

    @Schema(description = "用户ID")
    private String userId;

    @Schema(description = "客户ID")
    private String customerId;

    @Schema(description = "周期类型: DAILY / MONTHLY")
    private String periodType;

    @Schema(description = "周期key: yyyyMMdd / yyyyMM")
    private String periodKey;

    @Schema(description = "组织id")
    private String organizationId;
}
