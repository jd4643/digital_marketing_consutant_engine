package com.jd4643.strategyservice.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jd4643.strategyservice.exception.ApiError;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import java.util.Deque;
import java.util.LinkedList;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final int LIMIT = 30;
    private static final long WINDOW_MILLIS = 60_000;

    private final Map<String, Deque<Long>> requestsByIp = new ConcurrentHashMap<>();
    private final ObjectMapper objectMapper;

    public RateLimitingFilter(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        if (!request.getRequestURI().startsWith("/api/strategy")) {
            filterChain.doFilter(request, response);
            return;
        }

        String ip = request.getRemoteAddr();
        long now = Instant.now().toEpochMilli();
        Deque<Long> queue = requestsByIp.computeIfAbsent(ip, key -> new LinkedList<>());
        synchronized (queue) {
            while (!queue.isEmpty() && now - queue.peekFirst() > WINDOW_MILLIS) {
                queue.pollFirst();
            }
            if (queue.size() >= LIMIT) {
                response.setStatus(429);
                response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                response.getWriter().write(objectMapper.writeValueAsString(new ApiError("Rate limit exceeded")));
                return;
            }
            queue.addLast(now);
        }

        filterChain.doFilter(request, response);
    }
}
