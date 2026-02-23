package com.jd4643.strategyservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jd4643.strategyservice.config.OpenAiProperties;
import com.jd4643.strategyservice.model.StrategyRequest;
import com.jd4643.strategyservice.model.StrategyResponse;
import com.jd4643.strategyservice.util.PromptBuilder;
import com.openai.client.OpenAIClient;
import com.openai.models.ChatCompletion;
import com.openai.models.ChatCompletionCreateParams;
import com.openai.models.ChatModel;
import com.openai.models.ResponseFormatJsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class OpenAiStrategyClient {

    private static final Logger log = LoggerFactory.getLogger(OpenAiStrategyClient.class);

    private final OpenAIClient openAIClient;
    private final OpenAiProperties openAiProperties;
    private final ObjectMapper objectMapper;

    public OpenAiStrategyClient(OpenAIClient openAIClient, OpenAiProperties openAiProperties, ObjectMapper objectMapper) {
        this.openAIClient = openAIClient;
        this.openAiProperties = openAiProperties;
        this.objectMapper = objectMapper;
    }

    public StrategyResponse generate(StrategyRequest request) {
        long start = System.currentTimeMillis();
        ChatCompletionCreateParams params = ChatCompletionCreateParams.builder()
                .model(ChatModel.of(openAiProperties.model()))
                .addSystemMessage(PromptBuilder.systemPrompt())
                .addUserMessage(PromptBuilder.userPrompt(request))
                .temperature(0.3)
                .responseFormat(ResponseFormatJsonObject.builder().build())
                .build();

        ChatCompletion completion = openAIClient.chat().completions().create(params);
        long elapsed = System.currentTimeMillis() - start;
        log.info("OpenAI strategy response completed in {} ms", elapsed);

        String content = completion.choices().get(0).message().content().orElseThrow();
        try {
            return objectMapper.readValue(content, StrategyResponse.class);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to parse OpenAI response JSON", e);
        }
    }
}
