package com.jd4643.strategyservice.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jd4643.strategyservice.model.StrategyResponse;
import com.jd4643.strategyservice.service.StrategyService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(StrategyController.class)
class StrategyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private StrategyService strategyService;

    @Test
    void shouldReturn400WhenRequestIsInvalid() throws Exception {
        String invalidPayload = """
                {
                  "businessName": "",
                  "industry": "retail",
                  "product": "Shoes",
                  "priceRange": "$50-$100",
                  "location": "New York",
                  "monthlyBudget": 500,
                  "targetAudience": "Adults",
                  "objective": "sales",
                  "trends": []
                }
                """;

        mockMvc.perform(post("/api/strategy/generate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidPayload))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").exists());
    }

    @Test
    void shouldReturn200ForValidRequest() throws Exception {
        given(strategyService.generateStrategy(any())).willReturn(StrategyResponse.failure());

        String payload = """
                {
                  "businessName": "Acme",
                  "industry": "retail",
                  "product": "Shoes",
                  "priceRange": "$50-$100",
                  "location": "New York",
                  "monthlyBudget": 500,
                  "targetAudience": "Adults",
                  "objective": "sales",
                  "trends": []
                }
                """;

        mockMvc.perform(post("/api/strategy/generate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.error").value("Strategy generation failed"));
    }
}
