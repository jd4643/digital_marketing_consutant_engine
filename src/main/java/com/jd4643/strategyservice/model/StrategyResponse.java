package com.jd4643.strategyservice.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record StrategyResponse(
        PlatformBudgetSplit platformBudgetSplit,
        List<String> campaignPlan,
        String funnelStrategy,
        String expectedCPL,
        String expectedROAS,
        String reasoning,
        String error
) {
    public static StrategyResponse failure() {
        return new StrategyResponse(null, null, null, null, null, null, "Strategy generation failed");
    }
}
