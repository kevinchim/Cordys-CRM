package cn.cordys.crm.clue.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CluePoolPickRuleDTO {

    @NotNull
    @Schema(description = "是否限制领取数量")
    private Boolean limitOnNumber;

    @Schema(description = "领取数量")
    private Integer pickNumber;

    @NotNull
    @Schema(description = "是否限制前归属人领取")
    private Boolean limitPreOwner;

    @Schema(description = "领取间隔天数")
    private Integer pickIntervalDays;

    @NotNull
    @Schema(description = "是否限制新数据")
    private Boolean limitNew;

    @Schema(description = "新数据领取间隔")
    private Integer newPickInterval;

    @Schema(description = "是否限制每日可看")
    private Boolean limitDailyView;

    @Schema(description = "每日可看数量上限")
    private Integer dailyViewCount;

    @Schema(description = "是否限制每月可看")
    private Boolean limitMonthlyView;

    @Schema(description = "每月可看数量上限")
    private Integer monthlyViewCount;

    @Schema(description = "是否限制每月领取")
    private Boolean limitMonthlyPick;

    @Schema(description = "每月领取数量上限")
    private Integer monthlyPickCount;
}
