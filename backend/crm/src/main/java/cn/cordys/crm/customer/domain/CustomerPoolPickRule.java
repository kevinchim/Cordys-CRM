package cn.cordys.crm.customer.domain;

import cn.cordys.common.domain.BaseModel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Table(name = "customer_pool_pick_rule")
public class CustomerPoolPickRule extends BaseModel {

    @Schema(description = "公海池ID")
    private String poolId;

    @Schema(description = "是否限制每日领取数量")
    private Boolean limitOnNumber;

    @Schema(description = "领取数量")
    private Integer pickNumber;

    @Schema(description = "是否限制前归属人领取")
    private Boolean limitPreOwner;

    @Schema(description = "领取间隔天数")
    private Integer pickIntervalDays;

    @Schema(description = "是否限制新数据")
    private Boolean limitNew;

    @Schema(description = "新数据领取间隔")
    private Integer newPickInterval;

    @Schema(description = "是否限制每日可看")
    private Boolean limitDailyView = false;

    @Schema(description = "每日可看数量上限")
    private Integer dailyViewCount = 0;

    @Schema(description = "是否限制每月可看")
    private Boolean limitMonthlyView = false;

    @Schema(description = "每月可看数量上限")
    private Integer monthlyViewCount = 0;

    @Schema(description = "是否限制每月领取")
    private Boolean limitMonthlyPick = false;

    @Schema(description = "每月领取数量上限")
    private Integer monthlyPickCount = 0;
}
