package com.jd4643.strategyservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jd4643.strategyservice.model.Objective;
import com.jd4643.strategyservice.model.StrategyRequest;
import com.jd4643.strategyservice.model.StrategyResponse;
import com.jd4643.strategyservice.repository.StrategyHistoryRepository;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

class StrategyServiceTest {

    private final OpenAiStrategyClient openAiStrategyClient = mock(OpenAiStrategyClient.class);
    private final StrategyHistoryRepository strategyHistoryRepository = mock(StrategyHistoryRepository.class);
    private final StrategyService strategyService = new StrategyService(openAiStrategyClient, strategyHistoryRepository, new ObjectMapper());

    @Test
    void shouldUseSinglePlatformForLowBudget() {
        StrategyRequest request = new StrategyRequest(
                "Acme",
                "retail",
                "Shoes",
                "$50-$100",
                "NY",
                250,
                "Adults",
                Objective.SALES,
                List.of()
        );

        StrategyResponse response = strategyService.generateStrategy(request);

        assertThat(response.platformBudgetSplit().meta()).isEqualTo(250);
        assertThat(response.platformBudgetSplit().google()).isZero();
        assertThat(response.error()).isNull();
        verify(openAiStrategyClient, never()).generate(request);
    }
}
