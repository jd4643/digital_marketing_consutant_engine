package com.jd4643.strategyservice.model;

public record PlatformBudgetSplit(
        long meta,
        long google,
        long tiktok,
        long youtube
) {
}
