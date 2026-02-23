package com.jd4643.strategyservice.util;

import com.jd4643.strategyservice.model.StrategyRequest;
import java.util.Set;
import java.util.stream.Collectors;

public final class PromptBuilder {

    private static final Set<String> SUPPORTED_INDUSTRIES = Set.of(
            "ecommerce", "saas", "real estate", "healthcare", "education", "hospitality",
            "finance", "fitness", "beauty", "automotive", "retail"
    );

    private PromptBuilder() {
    }

    public static String systemPrompt() {
        return "You are a senior paid media strategist with 10+ years experience. " +
                "Focus on ROI, conversions, and realistic budget allocation. " +
                "Avoid generic advice. Use industry benchmarks. " +
                "Use provided trends only if relevant. If budget is low, focus on 1-2 platforms. " +
                "Return valid JSON only.";
    }

    public static String userPrompt(StrategyRequest request) {
        String trends = request.trends() == null || request.trends().isEmpty()
                ? "No trends provided."
                : request.trends().stream().collect(Collectors.joining(", "));
        String industrySupport = SUPPORTED_INDUSTRIES.contains(request.industry().toLowerCase())
                ? "Industry is supported."
                : "Industry may be unsupported. Use a generic performance marketing strategy.";

        return "Generate a practical and realistic ROI-focused paid media strategy in JSON with keys: " +
                "platformBudgetSplit, campaignPlan, funnelStrategy, expectedCPL, expectedROAS, reasoning. " +
                "businessName=" + request.businessName() + ", " +
                "industry=" + request.industry() + ", " +
                "product=" + request.product() + ", " +
                "priceRange=" + request.priceRange() + ", " +
                "location=" + request.location() + ", " +
                "monthlyBudget=" + request.monthlyBudget() + ", " +
                "targetAudience=" + request.targetAudience() + ", " +
                "objective=" + request.objective().toValue() + ", " +
                "trends(last 7 days)=" + trends + ". " +
                industrySupport;
    }
}
