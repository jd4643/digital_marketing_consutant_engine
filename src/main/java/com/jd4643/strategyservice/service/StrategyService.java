package com.jd4643.strategyservice.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jd4643.strategyservice.model.PlatformBudgetSplit;
import com.jd4643.strategyservice.model.StrategyHistory;
import com.jd4643.strategyservice.model.StrategyRequest;
import com.jd4643.strategyservice.model.StrategyResponse;
import com.jd4643.strategyservice.repository.StrategyHistoryRepository;
import java.time.Instant;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class StrategyService {

    private static final Logger log = LoggerFactory.getLogger(StrategyService.class);

    private final OpenAiStrategyClient openAiStrategyClient;
    private final StrategyHistoryRepository strategyHistoryRepository;
    private final ObjectMapper objectMapper;

    public StrategyService(
            OpenAiStrategyClient openAiStrategyClient,
            StrategyHistoryRepository strategyHistoryRepository,
            ObjectMapper objectMapper
    ) {
        this.openAiStrategyClient = openAiStrategyClient;
        this.strategyHistoryRepository = strategyHistoryRepository;
        this.objectMapper = objectMapper;
    }

    public StrategyResponse generateStrategy(StrategyRequest request) {
        StrategyResponse response;
        if (request.monthlyBudget() < 300) {
            response = lowBudgetResponse(request.monthlyBudget());
        } else {
            try {
                response = openAiStrategyClient.generate(request);
            } catch (Exception ex) {
                log.error("Strategy generation failed", ex);
                response = StrategyResponse.failure();
            }
        }
        persistHistory(request, response);
        return response;
    }

    private void persistHistory(StrategyRequest request, StrategyResponse response) {
        StrategyHistory history = new StrategyHistory();
        history.setBusinessName(request.businessName());
        history.setIndustry(request.industry());
        history.setBudget(request.monthlyBudget());
        history.setRequestJson(writeJson(request));
        history.setResponseJson(writeJson(response));
        history.setCreatedAt(Instant.now());
        strategyHistoryRepository.save(history);
    }

    private String writeJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (JsonProcessingException e) {
            log.warn("Failed to serialize strategy history payload", e);
            return "{}";
        }
    }

    private StrategyResponse lowBudgetResponse(long budget) {
        return new StrategyResponse(
                new PlatformBudgetSplit(budget, 0, 0, 0),
                List.of("Single conversion campaign on Meta with one high-intent ad set"),
                "TOF and BOF combined due to budget limits; optimize directly for conversions",
                "$8-$20",
                "1.2x-1.8x",
                "Budget below $300: concentrating on one platform improves signal density and efficiency.",
                null
        );
    }
}
