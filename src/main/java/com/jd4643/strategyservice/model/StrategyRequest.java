package com.jd4643.strategyservice.model;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record StrategyRequest(
        @NotBlank String businessName,
        @NotBlank String industry,
        @NotBlank String product,
        @NotBlank String priceRange,
        @NotBlank String location,
        @Min(1) long monthlyBudget,
        @NotBlank String targetAudience,
        @NotNull Objective objective,
        List<String> trends
) {
}
