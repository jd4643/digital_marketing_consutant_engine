package com.jd4643.strategyservice.repository;

import com.jd4643.strategyservice.model.StrategyHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StrategyHistoryRepository extends JpaRepository<StrategyHistory, Long> {
}
