package com.jd4643.strategyservice.controller;

import com.jd4643.strategyservice.model.StrategyRequest;
import com.jd4643.strategyservice.model.StrategyResponse;
import com.jd4643.strategyservice.service.StrategyService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/strategy")
public class StrategyController {

    private static final Logger log = LoggerFactory.getLogger(StrategyController.class);

    private final StrategyService strategyService;

    public StrategyController(StrategyService strategyService) {
        this.strategyService = strategyService;
    }

    @PostMapping("/generate")
    public ResponseEntity<StrategyResponse> generate(@Valid @RequestBody StrategyRequest request) {
        log.info("Incoming strategy request: businessName={}, industry={}, budget={}, objective={}",
                request.businessName(), request.industry(), request.monthlyBudget(), request.objective());
        return ResponseEntity.ok(strategyService.generateStrategy(request));
    }
}
