package com.jd4643.strategyservice.model;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum Objective {
    SALES,
    LEADS,
    TRAFFIC,
    AWARENESS;

    @JsonCreator
    public static Objective fromValue(String value) {
        return Objective.valueOf(value.toUpperCase());
    }

    @JsonValue
    public String toValue() {
        return name().toLowerCase();
    }
}
