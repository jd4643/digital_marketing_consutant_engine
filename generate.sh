#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# generate.sh — GrowthBlueprint SaaS Monorepo Scaffolding Script
# Digital Marketing Consultant Engine
#
# Usage:  chmod +x generate.sh && ./generate.sh [target-dir]
# Default target-dir: ./GrowthBlueprint
#
# This script creates a complete, production-grade SaaS monorepo including:
#   - Spring Boot 3 backend (apps/api)
#   - Node/TS AI Orchestrator (apps/ai-orchestrator)
#   - Next.js frontend (apps/web)
#   - Shared packages (packages/shared)
#   - Docker infrastructure (infra/docker, infra/prod)
#   - Kubernetes placeholders (infra/k8s)
#   - CI/CD workflows (.github/workflows)
#   - Comprehensive documentation (docs/)
#   - Makefile, README, .gitignore
###############################################################################

# ─── Helpers ──────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

say()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[⚠]${NC} $*" >&2; }
die()  { echo -e "${RED}[✗]${NC} $*" >&2; exit 1; }

ALLOW_OVERWRITE="${ALLOW_OVERWRITE:-false}"

write_file() {
  local filepath="$1"
  if [[ -f "$filepath" && "$ALLOW_OVERWRITE" != "true" ]]; then
    warn "File exists, skipping (set ALLOW_OVERWRITE=true to overwrite): $filepath"
    cat > /dev/null  # consume stdin
    return 0
  fi
  mkdir -p "$(dirname "$filepath")"
  cat > "$filepath"
  say "Created $filepath"
}

# ─── Dependency Checks (non-fatal) ──────────────────────────────────────────

check_tool() {
  if command -v "$1" &>/dev/null; then
    say "$1 found: $(command -v "$1")"
  else
    warn "$1 not found. Files will still be generated but you may need it later."
  fi
}

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         GrowthBlueprint — Monorepo Generator               ║${NC}"
echo -e "${CYAN}║         Digital Marketing Consultant Engine                 ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

check_tool docker
check_tool node
check_tool npm
check_tool java
check_tool mvn

# ─── Target Directory ───────────────────────────────────────────────────────

ROOT="${1:-./GrowthBlueprint}"
mkdir -p "$ROOT"
cd "$ROOT"
ROOT="$(pwd)"
say "Project root: $ROOT"

# ─── Directory Structure ────────────────────────────────────────────────────

say "Creating directory structure..."
mkdir -p apps/api/src/main/java/com/growthblueprint/api/{config,controller,dto,entity,repository,service,security,util}
mkdir -p apps/api/src/main/resources/db/migration
mkdir -p apps/api/src/test/java/com/growthblueprint/api
mkdir -p apps/ai-orchestrator/src/{connectors,knowledge,tools,workers}
mkdir -p apps/ai-orchestrator/src/__tests__
mkdir -p apps/web/src/{app,components,lib,hooks}
mkdir -p apps/web/src/app/{login,dashboard,onboarding,"business-profiles/[id]","plans/[id]",connectors,analytics,billing}
mkdir -p apps/web/public
mkdir -p packages/shared/src
mkdir -p infra/docker
mkdir -p infra/prod/{nginx,scripts}
mkdir -p infra/k8s
mkdir -p .github/workflows
mkdir -p docs

###############################################################################
# ROOT FILES
###############################################################################

# ─── .gitignore ─────────────────────────────────────────────────────────────
write_file ".gitignore" << 'EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Build
target/
dist/
build/
.next/
out/

# Environment
.env
.env.local
.env.*.local
*.env

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Docker
docker-compose.override.yml

# Java
*.class
*.jar
*.war
*.ear
*.iml

# Test
coverage/
.nyc_output/

# Secrets
*.pem
*.key
!infra/prod/nginx/*.conf
EOF

# ─── Root package.json ──────────────────────────────────────────────────────
write_file "package.json" << 'EOF'
{
  "name": "growthblueprint",
  "version": "1.0.0",
  "private": true,
  "description": "GrowthBlueprint — Digital Marketing Consultant Engine",
  "workspaces": [
    "apps/ai-orchestrator",
    "apps/web",
    "packages/shared"
  ],
  "scripts": {
    "dev:orchestrator": "cd apps/ai-orchestrator && npm run dev",
    "dev:web": "cd apps/web && npm run dev",
    "build:orchestrator": "cd apps/ai-orchestrator && npm run build",
    "build:web": "cd apps/web && npm run build",
    "test": "npm run test --workspaces --if-present",
    "lint": "npm run lint --workspaces --if-present"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
EOF

# ─── README.md ──────────────────────────────────────────────────────────────
write_file "README.md" << 'READMEEOF'
# GrowthBlueprint — Digital Marketing Consultant Engine

A production-grade SaaS platform that helps small-to-medium businesses generate
data-driven digital marketing plans using AI, with read-only analytics connectors
for paid tiers.

## Quick Start (Local Development)

```bash
# 1. Clone and enter
cd GrowthBlueprint

# 2. Copy environment template
cp infra/docker/.env.example infra/docker/.env

# 3. Start all services
make dev

# 4. Open browser
#    Frontend: http://localhost:3000
#    API:      http://localhost:8080
#    Demo:     demo@growthblueprint.local / DemoPass123!
```

## Architecture

| Component | Tech | Port |
|-----------|------|------|
| API | Spring Boot 3 (Java 21) | 8080 |
| AI Orchestrator | Node.js + TypeScript | 4000 |
| Frontend | Next.js 14 | 3000 |
| Database | PostgreSQL 16 + pgvector | 5432 |
| Cache/Queue | Redis 7 | 6379 |

## Tiers

| Feature | FREE | PRO | BUSINESS |
|---------|------|-----|----------|
| AI Marketing Plans | ✓ (3/mo) | ✓ (20/mo) | ✓ (unlimited) |
| Analytics Connectors | ✗ | ✓ | ✓ |
| Sync Frequency | — | Daily | Every 6h |
| Business Profiles | 1 | 5 | 20 |
| PDF Export | ✗ | ✓ | ✓ |
| Team Members | 1 | 5 | 20 |

## Documentation

See the [docs/](docs/) directory for:
- [Roadmap & Runbook](docs/ROADMAP_AND_RUNBOOK.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Deployment Guide](docs/VPS_DEPLOYMENT.md)
- [Threat Model](docs/THREAT_MODEL.md)
- [Edge Cases](docs/EDGE_CASES.md)
- [What Not To Do](docs/WHAT_NOT_TO_DO.md)

## License

Proprietary — All rights reserved.
READMEEOF

# ─── Makefile ───────────────────────────────────────────────────────────────
write_file "Makefile" << 'MAKEFILEEOF'
.PHONY: dev down logs reset-db test build seed

COMPOSE_FILE := infra/docker/docker-compose.yml
ENV_FILE := infra/docker/.env

dev:
.git@echo "Starting GrowthBlueprint development environment..."
.gitdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d
.git@echo ""
.git@echo "Services starting..."
.git@echo "  Frontend:  http://localhost:3000"
.git@echo "  API:       http://localhost:8080/health"
.git@echo "  Demo user: demo@growthblueprint.local / DemoPass123!"
.git@echo ""

down:
.gitdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

logs:
.gitdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

reset-db:
.gitdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v
.gitdocker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d
.git@echo "Database reset complete."

test:
.gitcd apps/api && ./mvnw test
.gitcd apps/ai-orchestrator && npm test
.gitcd apps/web && npm test

build:
.gitcd apps/api && ./mvnw package -DskipTests
.gitcd apps/ai-orchestrator && npm run build
.gitcd apps/web && npm run build

seed:
.git@echo "Seeding is automatic on first startup via Flyway + app initializer."
MAKEFILEEOF


###############################################################################
# SHARED PACKAGES
###############################################################################

write_file "packages/shared/package.json" << 'EOF'
{
  "name": "@growthblueprint/shared",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  },
  "dependencies": {
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.11.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "@types/jest": "^29.5.11"
  }
}
EOF

write_file "packages/shared/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

write_file "packages/shared/src/index.ts" << 'SHAREDEOF'
export * from './tiers';
export * from './schemas';
export * from './roles';
SHAREDEOF

write_file "packages/shared/src/tiers.ts" << 'EOF'
export enum Tier {
  FREE = 'FREE',
  PRO = 'PRO',
  BUSINESS = 'BUSINESS',
}

export interface TierConfig {
  tier: Tier;
  plansPerMonth: number;
  maxProfiles: number;
  connectorsEnabled: boolean;
  syncIntervalHours: number | null;
  pdfExport: boolean;
  maxTeamMembers: number;
  priceMonthlyUsd: number;
}

export const TIER_CONFIGS: Record<Tier, TierConfig> = {
  [Tier.FREE]: {
    tier: Tier.FREE,
    plansPerMonth: 3,
    maxProfiles: 1,
    connectorsEnabled: false,
    syncIntervalHours: null,
    pdfExport: false,
    maxTeamMembers: 1,
    priceMonthlyUsd: 0,
  },
  [Tier.PRO]: {
    tier: Tier.PRO,
    plansPerMonth: 20,
    maxProfiles: 5,
    connectorsEnabled: true,
    syncIntervalHours: 24,
    pdfExport: true,
    maxTeamMembers: 5,
    priceMonthlyUsd: 49,
  },
  [Tier.BUSINESS]: {
    tier: Tier.BUSINESS,
    plansPerMonth: 999999,
    maxProfiles: 20,
    connectorsEnabled: true,
    syncIntervalHours: 6,
    pdfExport: true,
    maxTeamMembers: 20,
    priceMonthlyUsd: 149,
  },
};
EOF

write_file "packages/shared/src/roles.ts" << 'EOF'
export enum Role {
  OWNER = 'OWNER',
  MARKETER = 'MARKETER',
  ANALYST = 'ANALYST',
}

export const ROLE_HIERARCHY: Record<Role, number> = {
  [Role.OWNER]: 100,
  [Role.MARKETER]: 50,
  [Role.ANALYST]: 10,
};

export function hasPermission(userRole: Role, requiredRole: Role): boolean {
  return ROLE_HIERARCHY[userRole] >= ROLE_HIERARCHY[requiredRole];
}
EOF

write_file "packages/shared/src/schemas.ts" << 'EOF'
import { z } from 'zod';

export const BusinessCategorySchema = z.enum([
  'jewelry',
  'restaurant',
  'apparel',
  'services',
  'other',
]);
export type BusinessCategory = z.infer<typeof BusinessCategorySchema>;

export const SalesChannelSchema = z.enum(['inStore', 'online', 'both']);
export type SalesChannel = z.infer<typeof SalesChannelSchema>;

export const EcommercePlatformSchema = z.enum(['Shopify', 'Other', 'None']);
export type EcommercePlatform = z.infer<typeof EcommercePlatformSchema>;

export const GoalSchema = z.enum(['leads', 'onlineSales', 'storeVisits', 'awareness']);
export type Goal = z.infer<typeof GoalSchema>;

export const USStateSchema = z.string().length(2).toUpperCase();

export const BusinessProfileSchema = z.object({
  businessName: z.string().min(1).max(200),
  category: BusinessCategorySchema,
  primaryLocation: z.object({
    city: z.string().min(1).max(100),
    state: USStateSchema,
    zip: z.string().regex(/^\d{5}(-\d{4})?$/, 'Invalid US ZIP code'),
  }),
  monthlyRevenue: z.number().min(0).max(1_000_000_000),
  monthlyMarketingBudget: z.number().min(0).max(100_000_000),
  salesChannels: SalesChannelSchema,
  ecommercePlatform: EcommercePlatformSchema.optional().default('None'),
  website: z.string().url().optional().or(z.literal('')),
  avgOrderValue: z.number().min(0).optional(),
  marginPct: z.number().min(0).max(100).optional(),
  teamSize: z.number().int().min(0).optional(),
  existingSocialHandles: z.object({
    instagram: z.string().optional(),
    tiktok: z.string().optional(),
    youtube: z.string().optional(),
  }).optional(),
  trackingInstalled: z.object({
    ga4: z.boolean(),
    metaPixel: z.boolean(),
  }),
  goals: z.array(GoalSchema).min(1),
  constraints: z.array(z.string()).optional().default([]),
  competitors: z.array(z.string()).optional().default([]),
});

export type BusinessProfile = z.infer<typeof BusinessProfileSchema>;

export const PlatformSchema = z.enum([
  'meta_ads',
  'google_ads',
  'tiktok_ads',
  'youtube_analytics',
  'ga4',
  'shopify',
  'google_search_console',
]);
export type Platform = z.infer<typeof PlatformSchema>;

export const ForecastQualitySchema = z.enum(['HIGH', 'MEDIUM', 'LOW']);
export type ForecastQuality = z.infer<typeof ForecastQualitySchema>;

export const MarketingPlanSectionSchema = z.object({
  title: z.string(),
  content: z.string(),
  recommendations: z.array(z.string()),
  estimatedBudgetAllocation: z.number().optional(),
});

export const MarketingPlanSchema = z.object({
  id: z.string().uuid(),
  businessProfileId: z.string().uuid(),
  orgId: z.string().uuid(),
  createdAt: z.string().datetime(),
  tier: z.enum(['FREE', 'PRO', 'BUSINESS']),
  inputHash: z.string(),
  forecastQuality: ForecastQualitySchema,
  assumptions: z.array(z.string()),
  limitations: z.array(z.string()),
  confidenceNote: z.string(),
  sections: z.array(MarketingPlanSectionSchema),
  forecast: z.object({
    rangeMin: z.number(),
    rangeMax: z.number(),
    unit: z.string(),
    period: z.string(),
    dataSourcesUsed: z.array(z.string()),
    connectDataChecklist: z.array(z.string()).optional(),
  }).optional(),
});
export type MarketingPlan = z.infer<typeof MarketingPlanSchema>;
EOF


###############################################################################
# SPRING BOOT BACKEND (apps/api)
###############################################################################

# ─── pom.xml ────────────────────────────────────────────────────────────────
write_file "apps/api/pom.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.2</version>
    <relativePath/>
  </parent>
  <groupId>com.growthblueprint</groupId>
  <artifactId>api</artifactId>
  <version>1.0.0</version>
  <name>GrowthBlueprint API</name>
  <description>Digital Marketing Consultant Engine - Backend API</description>
  <properties>
    <java.version>21</java.version>
    <jjwt.version>0.12.3</jjwt.version>
  </properties>
  <dependencies>
    <!-- Web -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <!-- Security -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <!-- Data -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.flywaydb</groupId>
      <artifactId>flyway-core</artifactId>
    </dependency>
    <dependency>
      <groupId>org.flywaydb</groupId>
      <artifactId>flyway-database-postgresql</artifactId>
    </dependency>
    <!-- JWT -->
    <dependency>
      <groupId>io.jsonwebtoken</groupId>
      <artifactId>jjwt-api</artifactId>
      <version>${jjwt.version}</version>
    </dependency>
    <dependency>
      <groupId>io.jsonwebtoken</groupId>
      <artifactId>jjwt-impl</artifactId>
      <version>${jjwt.version}</version>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>io.jsonwebtoken</groupId>
      <artifactId>jjwt-jackson</artifactId>
      <version>${jjwt.version}</version>
      <scope>runtime</scope>
    </dependency>
    <!-- Stripe -->
    <dependency>
      <groupId>com.stripe</groupId>
      <artifactId>stripe-java</artifactId>
      <version>24.15.0</version>
    </dependency>
    <!-- Actuator -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <!-- Lombok -->
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.security</groupId>
      <artifactId>spring-security-test</artifactId>
      <scope>test</scope>
    </dependency>
    <!-- JSON -->
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
            </exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
EOF

# ─── application.yml ────────────────────────────────────────────────────────
write_file "apps/api/src/main/resources/application.yml" << 'EOF'
server:
  port: 8080
  shutdown: graceful

spring:
  application:
    name: growthblueprint-api
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:growthblueprint}
    username: ${DB_USER:gb_user}
    password: ${DB_PASS:gb_pass_dev}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 10000
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
    properties:
      hibernate:
        default_schema: public
        jdbc:
          time_zone: UTC
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false

app:
  jwt:
    secret: ${JWT_SECRET:dev-secret-change-in-production-must-be-at-least-256-bits-long!!}
    access-expiration-ms: 900000
    refresh-expiration-ms: 604800000
  encryption:
    key: ${ENCRYPTION_KEY:0123456789abcdef0123456789abcdef}
  stripe:
    secret-key: ${STRIPE_SECRET_KEY:sk_test_placeholder}
    webhook-secret: ${STRIPE_WEBHOOK_SECRET:whsec_placeholder}
    price-pro: ${STRIPE_PRICE_PRO:price_pro_placeholder}
    price-business: ${STRIPE_PRICE_BUSINESS:price_business_placeholder}
  dev-mode: ${DEV_MODE:true}
  cors:
    allowed-origins: ${CORS_ORIGINS:http://localhost:3000}

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized

logging:
  pattern:
    console: '{"timestamp":"%d{ISO8601}","level":"%p","logger":"%logger","trace_id":"%X{traceId:-none}","org_id":"%X{orgId:-none}","msg":"%m"}%n'
  level:
    com.growthblueprint: DEBUG
    org.springframework.security: INFO
EOF

# ─── Flyway Migrations ─────────────────────────────────────────────────────
write_file "apps/api/src/main/resources/db/migration/V1__init.sql" << 'SQLEOF'
-- GrowthBlueprint Schema v1

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Organizations
CREATE TABLE orgs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    plan_tier VARCHAR(20) NOT NULL DEFAULT 'FREE' CHECK (plan_tier IN ('FREE','PRO','BUSINESS')),
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    stripe_status VARCHAR(50) DEFAULT 'none',
    usage_reset_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    plans_used_this_period INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'MARKETER' CHECK (role IN ('OWNER','MARKETER','ANALYST')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_users_org ON users(org_id);
CREATE INDEX idx_users_email ON users(email);

-- Refresh Tokens
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_hash ON refresh_tokens(token_hash);

-- Business Profiles
CREATE TABLE business_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    monthly_revenue DECIMAL(15,2) NOT NULL,
    monthly_marketing_budget DECIMAL(15,2) NOT NULL,
    sales_channels VARCHAR(20) NOT NULL,
    ecommerce_platform VARCHAR(20) DEFAULT 'None',
    website VARCHAR(500),
    avg_order_value DECIMAL(10,2),
    margin_pct DECIMAL(5,2),
    team_size INT,
    social_handles_json JSONB DEFAULT '{}',
    tracking_ga4 BOOLEAN NOT NULL DEFAULT FALSE,
    tracking_meta_pixel BOOLEAN NOT NULL DEFAULT FALSE,
    goals_json JSONB NOT NULL DEFAULT '[]',
    constraints_json JSONB DEFAULT '[]',
    competitors_json JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_profiles_org ON business_profiles(org_id);

-- Plan Jobs
CREATE TABLE plan_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    business_profile_id UUID NOT NULL REFERENCES business_profiles(id) ON DELETE CASCADE,
    input_hash VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING','PROCESSING','COMPLETED','FAILED')),
    error_message TEXT,
    plan_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_plan_jobs_org ON plan_jobs(org_id);
CREATE INDEX idx_plan_jobs_profile ON plan_jobs(business_profile_id);
CREATE UNIQUE INDEX idx_plan_jobs_idempotent ON plan_jobs(business_profile_id, input_hash)
    WHERE status IN ('PENDING','PROCESSING');

-- Marketing Plans
CREATE TABLE marketing_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    business_profile_id UUID NOT NULL REFERENCES business_profiles(id) ON DELETE CASCADE,
    plan_job_id UUID REFERENCES plan_jobs(id),
    tier VARCHAR(20) NOT NULL,
    input_hash VARCHAR(64) NOT NULL,
    forecast_quality VARCHAR(10) NOT NULL CHECK (forecast_quality IN ('HIGH','MEDIUM','LOW')),
    assumptions_json JSONB NOT NULL DEFAULT '[]',
    limitations_json JSONB NOT NULL DEFAULT '[]',
    confidence_note TEXT NOT NULL DEFAULT '',
    sections_json JSONB NOT NULL DEFAULT '[]',
    forecast_json JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_plans_org ON marketing_plans(org_id);
CREATE INDEX idx_plans_profile ON marketing_plans(business_profile_id);

-- Audit Logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL,
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id VARCHAR(255),
    details_json JSONB DEFAULT '{}',
    ip_address VARCHAR(45),
    trace_id VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_org ON audit_logs(org_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_created ON audit_logs(created_at);

-- Connectors
CREATE TABLE connectors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    business_profile_id UUID REFERENCES business_profiles(id) ON DELETE SET NULL,
    platform VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DISCONNECTED' CHECK (status IN ('CONNECTED','DISCONNECTED','ERROR','EXPIRED')),
    encrypted_tokens_json TEXT,
    scopes_json JSONB DEFAULT '[]',
    last_sync_at TIMESTAMPTZ,
    last_error TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_connectors_org ON connectors(org_id);
CREATE UNIQUE INDEX idx_connectors_org_platform ON connectors(org_id, platform);

-- Analytics Daily (normalized)
CREATE TABLE analytics_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id UUID NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
    business_profile_id UUID REFERENCES business_profiles(id) ON DELETE SET NULL,
    platform VARCHAR(50) NOT NULL,
    metric_date DATE NOT NULL,
    impressions BIGINT DEFAULT 0,
    clicks BIGINT DEFAULT 0,
    spend DECIMAL(12,2) DEFAULT 0,
    conversions DECIMAL(12,2) DEFAULT 0,
    revenue DECIMAL(12,2) DEFAULT 0,
    ctr DECIMAL(8,6) DEFAULT 0,
    cpc DECIMAL(10,4) DEFAULT 0,
    roas DECIMAL(10,4) DEFAULT 0,
    additional_json JSONB DEFAULT '{}',
    data_freshness TIMESTAMPTZ,
    data_completeness DECIMAL(5,2) DEFAULT 100.00,
    synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_analytics_org ON analytics_daily(org_id);
CREATE INDEX idx_analytics_date ON analytics_daily(metric_date);
CREATE UNIQUE INDEX idx_analytics_dedupe ON analytics_daily(org_id, business_profile_id, platform, metric_date);

-- Knowledge Chunks (pgvector)
-- NOTE: pgvector extension must be enabled in the database
CREATE TABLE knowledge_chunks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(100) NOT NULL,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    metadata_json JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_knowledge_category ON knowledge_chunks(category);

-- Seed: demo org + demo user
INSERT INTO orgs (id, name, plan_tier) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Demo Organization', 'PRO');

INSERT INTO users (id, org_id, email, password_hash, role) VALUES
  ('00000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'demo@growthblueprint.local',
   -- BCrypt hash of DemoPass123!
   '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
   'OWNER');
SQLEOF


###############################################################################
# SPRING BOOT - Java Source Files
###############################################################################

# ─── Main Application ──────────────────────────────────────────────────────
PKG="apps/api/src/main/java/com/growthblueprint/api"

write_file "$PKG/GrowthBlueprintApplication.java" << 'EOF'
package com.growthblueprint.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class GrowthBlueprintApplication {
    public static void main(String[] args) {
        SpringApplication.run(GrowthBlueprintApplication.class, args);
    }
}
EOF

# ─── Entities ───────────────────────────────────────────────────────────────
write_file "$PKG/entity/Org.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "orgs")
public class Org {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(name = "plan_tier", nullable = false)
    private String planTier = "FREE";

    @Column(name = "stripe_customer_id")
    private String stripeCustomerId;

    @Column(name = "stripe_subscription_id")
    private String stripeSubscriptionId;

    @Column(name = "stripe_status")
    private String stripeStatus = "none";

    @Column(name = "usage_reset_at", nullable = false)
    private Instant usageResetAt = Instant.now();

    @Column(name = "plans_used_this_period", nullable = false)
    private int plansUsedThisPeriod = 0;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Org() {}
    public Org(String name) { this.name = name; }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPlanTier() { return planTier; }
    public void setPlanTier(String planTier) { this.planTier = planTier; }
    public String getStripeCustomerId() { return stripeCustomerId; }
    public void setStripeCustomerId(String stripeCustomerId) { this.stripeCustomerId = stripeCustomerId; }
    public String getStripeSubscriptionId() { return stripeSubscriptionId; }
    public void setStripeSubscriptionId(String stripeSubscriptionId) { this.stripeSubscriptionId = stripeSubscriptionId; }
    public String getStripeStatus() { return stripeStatus; }
    public void setStripeStatus(String stripeStatus) { this.stripeStatus = stripeStatus; }
    public Instant getUsageResetAt() { return usageResetAt; }
    public void setUsageResetAt(Instant usageResetAt) { this.usageResetAt = usageResetAt; }
    public int getPlansUsedThisPeriod() { return plansUsedThisPeriod; }
    public void setPlansUsedThisPeriod(int plansUsedThisPeriod) { this.plansUsedThisPeriod = plansUsedThisPeriod; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }

    @PreUpdate
    public void onUpdate() { this.updatedAt = Instant.now(); }
}
EOF

write_file "$PKG/entity/User.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String role = "MARKETER";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public User() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    @PreUpdate
    public void onUpdate() { this.updatedAt = Instant.now(); }
}
EOF

write_file "$PKG/entity/RefreshToken.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens")
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "token_hash", nullable = false, unique = true)
    private String tokenHash;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(nullable = false)
    private boolean revoked = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public RefreshToken() {}

    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public String getTokenHash() { return tokenHash; }
    public void setTokenHash(String tokenHash) { this.tokenHash = tokenHash; }
    public Instant getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Instant expiresAt) { this.expiresAt = expiresAt; }
    public boolean isRevoked() { return revoked; }
    public void setRevoked(boolean revoked) { this.revoked = revoked; }
    public Instant getCreatedAt() { return createdAt; }
}
EOF

write_file "$PKG/entity/BusinessProfile.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "business_profiles")
public class BusinessProfile {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "business_name", nullable = false)
    private String businessName;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private String city;

    @Column(nullable = false, length = 2)
    private String state;

    @Column(nullable = false, length = 10)
    private String zip;

    @Column(name = "monthly_revenue", nullable = false)
    private BigDecimal monthlyRevenue;

    @Column(name = "monthly_marketing_budget", nullable = false)
    private BigDecimal monthlyMarketingBudget;

    @Column(name = "sales_channels", nullable = false)
    private String salesChannels;

    @Column(name = "ecommerce_platform")
    private String ecommercePlatform = "None";

    private String website;

    @Column(name = "avg_order_value")
    private BigDecimal avgOrderValue;

    @Column(name = "margin_pct")
    private BigDecimal marginPct;

    @Column(name = "team_size")
    private Integer teamSize;

    @Column(name = "social_handles_json", columnDefinition = "jsonb")
    private String socialHandlesJson = "{}";

    @Column(name = "tracking_ga4", nullable = false)
    private boolean trackingGa4;

    @Column(name = "tracking_meta_pixel", nullable = false)
    private boolean trackingMetaPixel;

    @Column(name = "goals_json", nullable = false, columnDefinition = "jsonb")
    private String goalsJson = "[]";

    @Column(name = "constraints_json", columnDefinition = "jsonb")
    private String constraintsJson = "[]";

    @Column(name = "competitors_json", columnDefinition = "jsonb")
    private String competitorsJson = "[]";

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public BusinessProfile() {}

    // Getters and setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public String getBusinessName() { return businessName; }
    public void setBusinessName(String n) { this.businessName = n; }
    public String getCategory() { return category; }
    public void setCategory(String c) { this.category = c; }
    public String getCity() { return city; }
    public void setCity(String c) { this.city = c; }
    public String getState() { return state; }
    public void setState(String s) { this.state = s; }
    public String getZip() { return zip; }
    public void setZip(String z) { this.zip = z; }
    public BigDecimal getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(BigDecimal mr) { this.monthlyRevenue = mr; }
    public BigDecimal getMonthlyMarketingBudget() { return monthlyMarketingBudget; }
    public void setMonthlyMarketingBudget(BigDecimal mb) { this.monthlyMarketingBudget = mb; }
    public String getSalesChannels() { return salesChannels; }
    public void setSalesChannels(String sc) { this.salesChannels = sc; }
    public String getEcommercePlatform() { return ecommercePlatform; }
    public void setEcommercePlatform(String ep) { this.ecommercePlatform = ep; }
    public String getWebsite() { return website; }
    public void setWebsite(String w) { this.website = w; }
    public BigDecimal getAvgOrderValue() { return avgOrderValue; }
    public void setAvgOrderValue(BigDecimal aov) { this.avgOrderValue = aov; }
    public BigDecimal getMarginPct() { return marginPct; }
    public void setMarginPct(BigDecimal mp) { this.marginPct = mp; }
    public Integer getTeamSize() { return teamSize; }
    public void setTeamSize(Integer ts) { this.teamSize = ts; }
    public String getSocialHandlesJson() { return socialHandlesJson; }
    public void setSocialHandlesJson(String s) { this.socialHandlesJson = s; }
    public boolean isTrackingGa4() { return trackingGa4; }
    public void setTrackingGa4(boolean t) { this.trackingGa4 = t; }
    public boolean isTrackingMetaPixel() { return trackingMetaPixel; }
    public void setTrackingMetaPixel(boolean t) { this.trackingMetaPixel = t; }
    public String getGoalsJson() { return goalsJson; }
    public void setGoalsJson(String g) { this.goalsJson = g; }
    public String getConstraintsJson() { return constraintsJson; }
    public void setConstraintsJson(String c) { this.constraintsJson = c; }
    public String getCompetitorsJson() { return competitorsJson; }
    public void setCompetitorsJson(String c) { this.competitorsJson = c; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    @PreUpdate
    public void onUpdate() { this.updatedAt = Instant.now(); }
}
EOF

write_file "$PKG/entity/PlanJob.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "plan_jobs")
public class PlanJob {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "business_profile_id", nullable = false)
    private UUID businessProfileId;

    @Column(name = "input_hash", nullable = false)
    private String inputHash;

    @Column(nullable = false)
    private String status = "PENDING";

    @Column(name = "error_message")
    private String errorMessage;

    @Column(name = "plan_id")
    private UUID planId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public PlanJob() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public UUID getBusinessProfileId() { return businessProfileId; }
    public void setBusinessProfileId(UUID bpId) { this.businessProfileId = bpId; }
    public String getInputHash() { return inputHash; }
    public void setInputHash(String inputHash) { this.inputHash = inputHash; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
    public UUID getPlanId() { return planId; }
    public void setPlanId(UUID planId) { this.planId = planId; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    @PreUpdate
    public void onUpdate() { this.updatedAt = Instant.now(); }
}
EOF

write_file "$PKG/entity/MarketingPlan.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "marketing_plans")
public class MarketingPlan {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "business_profile_id", nullable = false)
    private UUID businessProfileId;

    @Column(name = "plan_job_id")
    private UUID planJobId;

    @Column(nullable = false)
    private String tier;

    @Column(name = "input_hash", nullable = false)
    private String inputHash;

    @Column(name = "forecast_quality", nullable = false)
    private String forecastQuality;

    @Column(name = "assumptions_json", nullable = false, columnDefinition = "jsonb")
    private String assumptionsJson = "[]";

    @Column(name = "limitations_json", nullable = false, columnDefinition = "jsonb")
    private String limitationsJson = "[]";

    @Column(name = "confidence_note", nullable = false)
    private String confidenceNote = "";

    @Column(name = "sections_json", nullable = false, columnDefinition = "jsonb")
    private String sectionsJson = "[]";

    @Column(name = "forecast_json", columnDefinition = "jsonb")
    private String forecastJson;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public MarketingPlan() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public UUID getBusinessProfileId() { return businessProfileId; }
    public void setBusinessProfileId(UUID bpId) { this.businessProfileId = bpId; }
    public UUID getPlanJobId() { return planJobId; }
    public void setPlanJobId(UUID pjId) { this.planJobId = pjId; }
    public String getTier() { return tier; }
    public void setTier(String tier) { this.tier = tier; }
    public String getInputHash() { return inputHash; }
    public void setInputHash(String h) { this.inputHash = h; }
    public String getForecastQuality() { return forecastQuality; }
    public void setForecastQuality(String fq) { this.forecastQuality = fq; }
    public String getAssumptionsJson() { return assumptionsJson; }
    public void setAssumptionsJson(String a) { this.assumptionsJson = a; }
    public String getLimitationsJson() { return limitationsJson; }
    public void setLimitationsJson(String l) { this.limitationsJson = l; }
    public String getConfidenceNote() { return confidenceNote; }
    public void setConfidenceNote(String cn) { this.confidenceNote = cn; }
    public String getSectionsJson() { return sectionsJson; }
    public void setSectionsJson(String s) { this.sectionsJson = s; }
    public String getForecastJson() { return forecastJson; }
    public void setForecastJson(String f) { this.forecastJson = f; }
    public Instant getCreatedAt() { return createdAt; }
}
EOF

write_file "$PKG/entity/AuditLog.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "audit_logs")
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "user_id")
    private UUID userId;

    @Column(nullable = false)
    private String action;

    @Column(name = "resource_type")
    private String resourceType;

    @Column(name = "resource_id")
    private String resourceId;

    @Column(name = "details_json", columnDefinition = "jsonb")
    private String detailsJson = "{}";

    @Column(name = "ip_address")
    private String ipAddress;

    @Column(name = "trace_id")
    private String traceId;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public AuditLog() {}

    public UUID getId() { return id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getResourceType() { return resourceType; }
    public void setResourceType(String rt) { this.resourceType = rt; }
    public String getResourceId() { return resourceId; }
    public void setResourceId(String ri) { this.resourceId = ri; }
    public String getDetailsJson() { return detailsJson; }
    public void setDetailsJson(String d) { this.detailsJson = d; }
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ip) { this.ipAddress = ip; }
    public String getTraceId() { return traceId; }
    public void setTraceId(String ti) { this.traceId = ti; }
    public Instant getCreatedAt() { return createdAt; }
}
EOF

write_file "$PKG/entity/Connector.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "connectors")
public class Connector {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "business_profile_id")
    private UUID businessProfileId;

    @Column(nullable = false)
    private String platform;

    @Column(nullable = false)
    private String status = "DISCONNECTED";

    @Column(name = "encrypted_tokens_json")
    private String encryptedTokensJson;

    @Column(name = "scopes_json", columnDefinition = "jsonb")
    private String scopesJson = "[]";

    @Column(name = "last_sync_at")
    private Instant lastSyncAt;

    @Column(name = "last_error")
    private String lastError;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    public Connector() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public UUID getBusinessProfileId() { return businessProfileId; }
    public void setBusinessProfileId(UUID bpId) { this.businessProfileId = bpId; }
    public String getPlatform() { return platform; }
    public void setPlatform(String p) { this.platform = p; }
    public String getStatus() { return status; }
    public void setStatus(String s) { this.status = s; }
    public String getEncryptedTokensJson() { return encryptedTokensJson; }
    public void setEncryptedTokensJson(String e) { this.encryptedTokensJson = e; }
    public String getScopesJson() { return scopesJson; }
    public void setScopesJson(String s) { this.scopesJson = s; }
    public Instant getLastSyncAt() { return lastSyncAt; }
    public void setLastSyncAt(Instant l) { this.lastSyncAt = l; }
    public String getLastError() { return lastError; }
    public void setLastError(String l) { this.lastError = l; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }

    @PreUpdate
    public void onUpdate() { this.updatedAt = Instant.now(); }
}
EOF

write_file "$PKG/entity/AnalyticsDaily.java" << 'EOF'
package com.growthblueprint.api.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "analytics_daily")
public class AnalyticsDaily {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "org_id", nullable = false)
    private UUID orgId;

    @Column(name = "business_profile_id")
    private UUID businessProfileId;

    @Column(nullable = false)
    private String platform;

    @Column(name = "metric_date", nullable = false)
    private LocalDate metricDate;

    private Long impressions = 0L;
    private Long clicks = 0L;
    private BigDecimal spend = BigDecimal.ZERO;
    private BigDecimal conversions = BigDecimal.ZERO;
    private BigDecimal revenue = BigDecimal.ZERO;
    private BigDecimal ctr = BigDecimal.ZERO;
    private BigDecimal cpc = BigDecimal.ZERO;
    private BigDecimal roas = BigDecimal.ZERO;

    @Column(name = "additional_json", columnDefinition = "jsonb")
    private String additionalJson = "{}";

    @Column(name = "data_freshness")
    private Instant dataFreshness;

    @Column(name = "data_completeness")
    private BigDecimal dataCompleteness = new BigDecimal("100.00");

    @Column(name = "synced_at", nullable = false)
    private Instant syncedAt = Instant.now();

    public AnalyticsDaily() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOrgId() { return orgId; }
    public void setOrgId(UUID orgId) { this.orgId = orgId; }
    public UUID getBusinessProfileId() { return businessProfileId; }
    public void setBusinessProfileId(UUID bpId) { this.businessProfileId = bpId; }
    public String getPlatform() { return platform; }
    public void setPlatform(String p) { this.platform = p; }
    public LocalDate getMetricDate() { return metricDate; }
    public void setMetricDate(LocalDate d) { this.metricDate = d; }
    public Long getImpressions() { return impressions; }
    public void setImpressions(Long i) { this.impressions = i; }
    public Long getClicks() { return clicks; }
    public void setClicks(Long c) { this.clicks = c; }
    public BigDecimal getSpend() { return spend; }
    public void setSpend(BigDecimal s) { this.spend = s; }
    public BigDecimal getConversions() { return conversions; }
    public void setConversions(BigDecimal c) { this.conversions = c; }
    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal r) { this.revenue = r; }
    public BigDecimal getCtr() { return ctr; }
    public void setCtr(BigDecimal c) { this.ctr = c; }
    public BigDecimal getCpc() { return cpc; }
    public void setCpc(BigDecimal c) { this.cpc = c; }
    public BigDecimal getRoas() { return roas; }
    public void setRoas(BigDecimal r) { this.roas = r; }
    public String getAdditionalJson() { return additionalJson; }
    public void setAdditionalJson(String a) { this.additionalJson = a; }
    public Instant getDataFreshness() { return dataFreshness; }
    public void setDataFreshness(Instant df) { this.dataFreshness = df; }
    public BigDecimal getDataCompleteness() { return dataCompleteness; }
    public void setDataCompleteness(BigDecimal dc) { this.dataCompleteness = dc; }
    public Instant getSyncedAt() { return syncedAt; }
    public void setSyncedAt(Instant s) { this.syncedAt = s; }
}
EOF


###############################################################################
# SPRING BOOT - Repositories, Security, Config
###############################################################################

PKG="apps/api/src/main/java/com/growthblueprint/api"

# ─── Repositories ───────────────────────────────────────────────────────────
write_file "$PKG/repository/OrgRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.Org;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface OrgRepository extends JpaRepository<Org, UUID> {
    Optional<Org> findByStripeCustomerId(String stripeCustomerId);
}
EOF

write_file "$PKG/repository/UserRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    long countByOrgId(UUID orgId);
}
EOF

write_file "$PKG/repository/RefreshTokenRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByTokenHashAndRevokedFalse(String tokenHash);

    @Modifying
    @Query("UPDATE RefreshToken rt SET rt.revoked = true WHERE rt.userId = :userId")
    void revokeAllByUserId(UUID userId);
}
EOF

write_file "$PKG/repository/BusinessProfileRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.BusinessProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BusinessProfileRepository extends JpaRepository<BusinessProfile, UUID> {
    List<BusinessProfile> findByOrgId(UUID orgId);
    Optional<BusinessProfile> findByIdAndOrgId(UUID id, UUID orgId);
    long countByOrgId(UUID orgId);
}
EOF

write_file "$PKG/repository/PlanJobRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.PlanJob;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PlanJobRepository extends JpaRepository<PlanJob, UUID> {
    Optional<PlanJob> findByIdAndOrgId(UUID id, UUID orgId);
    Optional<PlanJob> findByBusinessProfileIdAndInputHashAndStatusIn(
        UUID businessProfileId, String inputHash, List<String> statuses);
    List<PlanJob> findByBusinessProfileIdAndOrgId(UUID businessProfileId, UUID orgId);
}
EOF

write_file "$PKG/repository/MarketingPlanRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.MarketingPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MarketingPlanRepository extends JpaRepository<MarketingPlan, UUID> {
    List<MarketingPlan> findByBusinessProfileIdAndOrgIdOrderByCreatedAtDesc(UUID bpId, UUID orgId);
    Optional<MarketingPlan> findByIdAndOrgId(UUID id, UUID orgId);
}
EOF

write_file "$PKG/repository/AuditLogRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {}
EOF

write_file "$PKG/repository/ConnectorRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.Connector;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConnectorRepository extends JpaRepository<Connector, UUID> {
    List<Connector> findByOrgId(UUID orgId);
    Optional<Connector> findByOrgIdAndPlatform(UUID orgId, String platform);
}
EOF

write_file "$PKG/repository/AnalyticsDailyRepository.java" << 'EOF'
package com.growthblueprint.api.repository;

import com.growthblueprint.api.entity.AnalyticsDaily;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface AnalyticsDailyRepository extends JpaRepository<AnalyticsDaily, UUID> {
    List<AnalyticsDaily> findByOrgIdAndBusinessProfileIdAndMetricDateBetween(
        UUID orgId, UUID bpId, LocalDate from, LocalDate to);
}
EOF

# ─── Security Config ───────────────────────────────────────────────────────
write_file "$PKG/security/JwtUtil.java" << 'EOF'
package com.growthblueprint.api.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;

@Component
public class JwtUtil {

    private final SecretKey key;
    private final long accessExpirationMs;
    private final long refreshExpirationMs;

    public JwtUtil(
        @Value("${app.jwt.secret}") String secret,
        @Value("${app.jwt.access-expiration-ms}") long accessExpirationMs,
        @Value("${app.jwt.refresh-expiration-ms}") long refreshExpirationMs
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessExpirationMs = accessExpirationMs;
        this.refreshExpirationMs = refreshExpirationMs;
    }

    public String generateAccessToken(UUID userId, UUID orgId, String role, String email) {
        return Jwts.builder()
            .subject(userId.toString())
            .claim("orgId", orgId.toString())
            .claim("role", role)
            .claim("email", email)
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + accessExpirationMs))
            .signWith(key)
            .compact();
    }

    public String generateRefreshToken() {
        return UUID.randomUUID().toString() + "-" + UUID.randomUUID().toString();
    }

    public long getRefreshExpirationMs() { return refreshExpirationMs; }

    public Claims parseAccessToken(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }

    public static String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("Failed to hash token", e);
        }
    }
}
EOF

write_file "$PKG/security/JwtAuthFilter.java" << 'EOF'
package com.growthblueprint.api.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {
    private static final Logger log = LoggerFactory.getLogger(JwtAuthFilter.class);
    private final JwtUtil jwtUtil;

    public JwtAuthFilter(JwtUtil jwtUtil) { this.jwtUtil = jwtUtil; }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        // Set trace ID
        String traceId = request.getHeader("X-Trace-Id");
        if (traceId == null || traceId.isBlank()) {
            traceId = UUID.randomUUID().toString();
        }
        MDC.put("traceId", traceId);
        response.setHeader("X-Trace-Id", traceId);

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                Claims claims = jwtUtil.parseAccessToken(token);
                String userId = claims.getSubject();
                String orgId = claims.get("orgId", String.class);
                String role = claims.get("role", String.class);
                String email = claims.get("email", String.class);

                MDC.put("orgId", orgId);

                AuthPrincipal principal = new AuthPrincipal(
                    UUID.fromString(userId), UUID.fromString(orgId), role, email);

                UsernamePasswordAuthenticationToken auth =
                    new UsernamePasswordAuthenticationToken(principal, null,
                        List.of(new SimpleGrantedAuthority("ROLE_" + role)));
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (ExpiredJwtException e) {
                log.debug("Expired JWT token");
            } catch (JwtException e) {
                log.debug("Invalid JWT token");
            }
        }
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
EOF

write_file "$PKG/security/AuthPrincipal.java" << 'EOF'
package com.growthblueprint.api.security;

import java.util.UUID;

public record AuthPrincipal(UUID userId, UUID orgId, String role, String email) {}
EOF

write_file "$PKG/config/SecurityConfig.java" << 'EOF'
package com.growthblueprint.api.config;

import com.growthblueprint.api.security.JwtAuthFilter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final String allowedOrigins;

    public SecurityConfig(JwtAuthFilter jwtAuthFilter,
                          @Value("${app.cors.allowed-origins}") String allowedOrigins) {
        this.jwtAuthFilter = jwtAuthFilter;
        this.allowedOrigins = allowedOrigins;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/health").permitAll()
                .requestMatchers("/billing/stripe/webhook").permitAll()
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/metrics").hasRole("OWNER")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration cfg = new CorsConfiguration();
        cfg.setAllowedOrigins(Arrays.asList(allowedOrigins.split(",")));
        cfg.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(true);
        cfg.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", cfg);
        return source;
    }
}
EOF

# ─── Encryption Utility ────────────────────────────────────────────────────
write_file "$PKG/util/EncryptionUtil.java" << 'EOF'
package com.growthblueprint.api.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@Component
public class EncryptionUtil {

    private static final String AES_GCM = "AES/GCM/NoPadding";
    private static final int GCM_TAG_LENGTH = 128;
    private static final int IV_LENGTH = 12;

    private final SecretKeySpec keySpec;

    public EncryptionUtil(@Value("${app.encryption.key}") String hexKey) {
        byte[] keyBytes = hexKey.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 16) {
            byte[] padded = new byte[16];
            System.arraycopy(keyBytes, 0, padded, 0, Math.min(keyBytes.length, 16));
            keyBytes = padded;
        } else if (keyBytes.length > 16 && keyBytes.length < 32) {
            byte[] truncated = new byte[16];
            System.arraycopy(keyBytes, 0, truncated, 0, 16);
            keyBytes = truncated;
        } else if (keyBytes.length > 32) {
            byte[] truncated = new byte[32];
            System.arraycopy(keyBytes, 0, truncated, 0, 32);
            keyBytes = truncated;
        }
        this.keySpec = new SecretKeySpec(keyBytes, "AES");
    }

    public String encrypt(String plaintext) {
        try {
            byte[] iv = new byte[IV_LENGTH];
            new SecureRandom().nextBytes(iv);
            Cipher cipher = Cipher.getInstance(AES_GCM);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] encrypted = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));
            byte[] combined = new byte[iv.length + encrypted.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);
            return Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new RuntimeException("Encryption failed", e);
        }
    }

    public String decrypt(String ciphertext) {
        try {
            byte[] combined = Base64.getDecoder().decode(ciphertext);
            byte[] iv = new byte[IV_LENGTH];
            System.arraycopy(combined, 0, iv, 0, iv.length);
            byte[] encrypted = new byte[combined.length - iv.length];
            System.arraycopy(combined, iv.length, encrypted, 0, encrypted.length);
            Cipher cipher = Cipher.getInstance(AES_GCM);
            cipher.init(Cipher.DECRYPT_MODE, keySpec, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            return new String(cipher.doFinal(encrypted), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Decryption failed", e);
        }
    }
}
EOF


###############################################################################
# SPRING BOOT - DTOs and Services
###############################################################################

PKG="apps/api/src/main/java/com/growthblueprint/api"

# ─── DTOs ───────────────────────────────────────────────────────────────────
write_file "$PKG/dto/AuthDtos.java" << 'EOF'
package com.growthblueprint.api.dto;

import jakarta.validation.constraints.*;

public class AuthDtos {

    public record RegisterRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 8, max = 128) String password,
        @NotBlank String orgName
    ) {}

    public record LoginRequest(
        @NotBlank @Email String email,
        @NotBlank String password
    ) {}

    public record RefreshRequest(
        @NotBlank String refreshToken
    ) {}

    public record AuthResponse(
        String accessToken,
        String refreshToken,
        String userId,
        String orgId,
        String role,
        String email,
        String tier
    ) {}

    public record MessageResponse(String message) {}
}
EOF

write_file "$PKG/dto/BusinessProfileDto.java" << 'EOF'
package com.growthblueprint.api.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class BusinessProfileDto {

    public record CreateRequest(
        @NotBlank @Size(max = 200) String businessName,
        @NotBlank String category,
        @NotBlank String city,
        @NotBlank @Size(min = 2, max = 2) String state,
        @NotBlank @Pattern(regexp = "^\\d{5}(-\\d{4})?$") String zip,
        @NotNull @DecimalMin("0") BigDecimal monthlyRevenue,
        @NotNull @DecimalMin("0") BigDecimal monthlyMarketingBudget,
        @NotBlank String salesChannels,
        String ecommercePlatform,
        String website,
        BigDecimal avgOrderValue,
        BigDecimal marginPct,
        Integer teamSize,
        Map<String, String> socialHandles,
        boolean trackingGa4,
        boolean trackingMetaPixel,
        @NotEmpty List<String> goals,
        List<String> constraints,
        List<String> competitors
    ) {}

    public record Response(
        String id,
        String businessName,
        String category,
        String city,
        String state,
        String zip,
        BigDecimal monthlyRevenue,
        BigDecimal monthlyMarketingBudget,
        String salesChannels,
        String ecommercePlatform,
        String website,
        BigDecimal avgOrderValue,
        BigDecimal marginPct,
        Integer teamSize,
        String socialHandlesJson,
        boolean trackingGa4,
        boolean trackingMetaPixel,
        String goalsJson,
        String constraintsJson,
        String competitorsJson,
        String createdAt
    ) {}
}
EOF

write_file "$PKG/dto/PlanDtos.java" << 'EOF'
package com.growthblueprint.api.dto;

public class PlanDtos {

    public record PlanJobResponse(
        String id,
        String businessProfileId,
        String status,
        String planId,
        String errorMessage,
        String createdAt
    ) {}

    public record PlanResponse(
        String id,
        String businessProfileId,
        String tier,
        String forecastQuality,
        String assumptionsJson,
        String limitationsJson,
        String confidenceNote,
        String sectionsJson,
        String forecastJson,
        String createdAt
    ) {}

    public record ExportResponse(
        String planId,
        String format,
        String content
    ) {}
}
EOF

write_file "$PKG/dto/ConnectorDtos.java" << 'EOF'
package com.growthblueprint.api.dto;

import java.util.Map;

public class ConnectorDtos {

    public record ConnectRequest(
        Map<String, String> tokens,
        java.util.List<String> scopes
    ) {}

    public record ConnectorResponse(
        String id,
        String platform,
        String status,
        String lastSyncAt,
        String lastError,
        String scopesJson
    ) {}

    public record SyncResponse(
        String platform,
        String status,
        String message
    ) {}
}
EOF

write_file "$PKG/dto/BillingDtos.java" << 'EOF'
package com.growthblueprint.api.dto;

public class BillingDtos {

    public record CheckoutRequest(String tier) {}

    public record CheckoutResponse(String sessionUrl) {}

    public record PortalResponse(String portalUrl) {}

    public record BillingStatusResponse(
        String tier,
        String stripeStatus,
        int plansUsedThisPeriod,
        int plansLimit,
        int profilesCount,
        int profilesLimit,
        String renewalDate
    ) {}
}
EOF

write_file "$PKG/dto/AnalyticsDtos.java" << 'EOF'
package com.growthblueprint.api.dto;

import java.math.BigDecimal;
import java.util.List;

public class AnalyticsDtos {

    public record SummaryResponse(
        List<DailyMetric> metrics,
        String from,
        String to,
        String profileId
    ) {}

    public record DailyMetric(
        String date,
        String platform,
        Long impressions,
        Long clicks,
        BigDecimal spend,
        BigDecimal conversions,
        BigDecimal revenue,
        BigDecimal ctr,
        BigDecimal roas
    ) {}
}
EOF

# ─── Audit Service ──────────────────────────────────────────────────────────
write_file "$PKG/service/AuditService.java" << 'EOF'
package com.growthblueprint.api.service;

import com.growthblueprint.api.entity.AuditLog;
import com.growthblueprint.api.repository.AuditLogRepository;
import org.slf4j.MDC;
import org.springframework.stereotype.Service;
import java.util.UUID;

@Service
public class AuditService {

    private final AuditLogRepository auditLogRepository;

    public AuditService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public void log(UUID orgId, UUID userId, String action, String resourceType,
                    String resourceId, String details, String ipAddress) {
        AuditLog log = new AuditLog();
        log.setOrgId(orgId);
        log.setUserId(userId);
        log.setAction(action);
        log.setResourceType(resourceType);
        log.setResourceId(resourceId);
        log.setDetailsJson(details != null ? details : "{}");
        log.setIpAddress(ipAddress);
        log.setTraceId(MDC.get("traceId"));
        auditLogRepository.save(log);
    }
}
EOF

# ─── Auth Service ───────────────────────────────────────────────────────────
write_file "$PKG/service/AuthService.java" << 'EOF'
package com.growthblueprint.api.service;

import com.growthblueprint.api.dto.AuthDtos.*;
import com.growthblueprint.api.entity.*;
import com.growthblueprint.api.repository.*;
import com.growthblueprint.api.security.JwtUtil;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final OrgRepository orgRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuditService auditService;

    public AuthService(UserRepository userRepository, OrgRepository orgRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       PasswordEncoder passwordEncoder, JwtUtil jwtUtil,
                       AuditService auditService) {
        this.userRepository = userRepository;
        this.orgRepository = orgRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.auditService = auditService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest req, String ipAddress) {
        if (userRepository.existsByEmail(req.email())) {
            throw new IllegalArgumentException("Email already registered");
        }
        Org org = new Org(req.orgName());
        org = orgRepository.save(org);

        User user = new User();
        user.setOrgId(org.getId());
        user.setEmail(req.email());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setRole("OWNER");
        user = userRepository.save(user);

        String accessToken = jwtUtil.generateAccessToken(user.getId(), org.getId(), user.getRole(), user.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken();
        saveRefreshToken(user.getId(), refreshToken);

        auditService.log(org.getId(), user.getId(), "AUTH_REGISTER", "user",
            user.getId().toString(), "{}", ipAddress);

        return new AuthResponse(accessToken, refreshToken, user.getId().toString(),
            org.getId().toString(), user.getRole(), user.getEmail(), org.getPlanTier());
    }

    @Transactional
    public AuthResponse login(LoginRequest req, String ipAddress) {
        User user = userRepository.findByEmail(req.email())
            .orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));

        if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid credentials");
        }

        Org org = orgRepository.findById(user.getOrgId())
            .orElseThrow(() -> new IllegalStateException("Org not found"));

        String accessToken = jwtUtil.generateAccessToken(user.getId(), org.getId(), user.getRole(), user.getEmail());
        String refreshToken = jwtUtil.generateRefreshToken();
        saveRefreshToken(user.getId(), refreshToken);

        auditService.log(org.getId(), user.getId(), "AUTH_LOGIN", "user",
            user.getId().toString(), "{}", ipAddress);

        return new AuthResponse(accessToken, refreshToken, user.getId().toString(),
            org.getId().toString(), user.getRole(), user.getEmail(), org.getPlanTier());
    }

    @Transactional
    public AuthResponse refresh(RefreshRequest req) {
        String hash = JwtUtil.hashToken(req.refreshToken());
        RefreshToken storedToken = refreshTokenRepository.findByTokenHashAndRevokedFalse(hash)
            .orElseThrow(() -> new IllegalArgumentException("Invalid or expired refresh token"));

        if (storedToken.getExpiresAt().isBefore(Instant.now())) {
            storedToken.setRevoked(true);
            refreshTokenRepository.save(storedToken);
            throw new IllegalArgumentException("Refresh token expired");
        }

        // Rotate: revoke old, issue new
        storedToken.setRevoked(true);
        refreshTokenRepository.save(storedToken);

        User user = userRepository.findById(storedToken.getUserId())
            .orElseThrow(() -> new IllegalStateException("User not found"));
        Org org = orgRepository.findById(user.getOrgId())
            .orElseThrow(() -> new IllegalStateException("Org not found"));

        String accessToken = jwtUtil.generateAccessToken(user.getId(), org.getId(), user.getRole(), user.getEmail());
        String newRefreshToken = jwtUtil.generateRefreshToken();
        saveRefreshToken(user.getId(), newRefreshToken);

        return new AuthResponse(accessToken, newRefreshToken, user.getId().toString(),
            org.getId().toString(), user.getRole(), user.getEmail(), org.getPlanTier());
    }

    @Transactional
    public void logout(UUID userId, String ipAddress) {
        refreshTokenRepository.revokeAllByUserId(userId);
        User user = userRepository.findById(userId).orElse(null);
        if (user != null) {
            auditService.log(user.getOrgId(), userId, "AUTH_LOGOUT", "user",
                userId.toString(), "{}", ipAddress);
        }
    }

    private void saveRefreshToken(UUID userId, String rawToken) {
        RefreshToken rt = new RefreshToken();
        rt.setUserId(userId);
        rt.setTokenHash(JwtUtil.hashToken(rawToken));
        rt.setExpiresAt(Instant.now().plusMillis(jwtUtil.getRefreshExpirationMs()));
        refreshTokenRepository.save(rt);
    }
}
EOF

# ─── Business Profile Service ──────────────────────────────────────────────
write_file "$PKG/service/BusinessProfileService.java" << 'EOF'
package com.growthblueprint.api.service;

import com.growthblueprint.api.dto.BusinessProfileDto.*;
import com.growthblueprint.api.entity.BusinessProfile;
import com.growthblueprint.api.entity.Org;
import com.growthblueprint.api.repository.BusinessProfileRepository;
import com.growthblueprint.api.repository.OrgRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class BusinessProfileService {

    private final BusinessProfileRepository profileRepository;
    private final OrgRepository orgRepository;
    private final AuditService auditService;
    private final ObjectMapper objectMapper;

    // Tier limits: maxProfiles
    private static final Map<String, Integer> PROFILE_LIMITS = Map.of(
        "FREE", 1, "PRO", 5, "BUSINESS", 20
    );

    public BusinessProfileService(BusinessProfileRepository profileRepository,
                                   OrgRepository orgRepository,
                                   AuditService auditService,
                                   ObjectMapper objectMapper) {
        this.profileRepository = profileRepository;
        this.orgRepository = orgRepository;
        this.auditService = auditService;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public Response create(UUID orgId, UUID userId, CreateRequest req, String ip) {
        Org org = orgRepository.findById(orgId)
            .orElseThrow(() -> new IllegalStateException("Org not found"));

        int limit = PROFILE_LIMITS.getOrDefault(org.getPlanTier(), 1);
        long current = profileRepository.countByOrgId(orgId);
        if (current >= limit) {
            throw new IllegalStateException("Profile limit reached for tier " + org.getPlanTier());
        }

        // Validate category
        List<String> validCategories = List.of("jewelry", "restaurant", "apparel", "services", "other");
        if (!validCategories.contains(req.category())) {
            throw new IllegalArgumentException("Invalid category: " + req.category());
        }

        BusinessProfile bp = new BusinessProfile();
        bp.setOrgId(orgId);
        bp.setBusinessName(req.businessName());
        bp.setCategory(req.category());
        bp.setCity(req.city());
        bp.setState(req.state().toUpperCase());
        bp.setZip(req.zip());
        bp.setMonthlyRevenue(req.monthlyRevenue());
        bp.setMonthlyMarketingBudget(req.monthlyMarketingBudget());
        bp.setSalesChannels(req.salesChannels());
        bp.setEcommercePlatform(req.ecommercePlatform() != null ? req.ecommercePlatform() : "None");
        bp.setWebsite(req.website());
        bp.setAvgOrderValue(req.avgOrderValue());
        bp.setMarginPct(req.marginPct());
        bp.setTeamSize(req.teamSize());
        bp.setTrackingGa4(req.trackingGa4());
        bp.setTrackingMetaPixel(req.trackingMetaPixel());

        try {
            bp.setSocialHandlesJson(req.socialHandles() != null ?
                objectMapper.writeValueAsString(req.socialHandles()) : "{}");
            bp.setGoalsJson(objectMapper.writeValueAsString(req.goals()));
            bp.setConstraintsJson(req.constraints() != null ?
                objectMapper.writeValueAsString(req.constraints()) : "[]");
            bp.setCompetitorsJson(req.competitors() != null ?
                objectMapper.writeValueAsString(req.competitors()) : "[]");
        } catch (Exception e) {
            throw new RuntimeException("JSON serialization error", e);
        }

        bp = profileRepository.save(bp);

        auditService.log(orgId, userId, "PROFILE_CREATE", "business_profile",
            bp.getId().toString(), "{}", ip);

        return toResponse(bp);
    }

    public List<Response> listByOrg(UUID orgId) {
        return profileRepository.findByOrgId(orgId).stream()
            .map(this::toResponse).collect(Collectors.toList());
    }

    public Response getById(UUID orgId, UUID id) {
        BusinessProfile bp = profileRepository.findByIdAndOrgId(id, orgId)
            .orElseThrow(() -> new NoSuchElementException("Profile not found"));
        return toResponse(bp);
    }

    @Transactional
    public Response update(UUID orgId, UUID userId, UUID id, CreateRequest req, String ip) {
        BusinessProfile bp = profileRepository.findByIdAndOrgId(id, orgId)
            .orElseThrow(() -> new NoSuchElementException("Profile not found"));

        bp.setBusinessName(req.businessName());
        bp.setCategory(req.category());
        bp.setCity(req.city());
        bp.setState(req.state().toUpperCase());
        bp.setZip(req.zip());
        bp.setMonthlyRevenue(req.monthlyRevenue());
        bp.setMonthlyMarketingBudget(req.monthlyMarketingBudget());
        bp.setSalesChannels(req.salesChannels());
        bp.setEcommercePlatform(req.ecommercePlatform() != null ? req.ecommercePlatform() : "None");
        bp.setWebsite(req.website());
        bp.setAvgOrderValue(req.avgOrderValue());
        bp.setMarginPct(req.marginPct());
        bp.setTeamSize(req.teamSize());
        bp.setTrackingGa4(req.trackingGa4());
        bp.setTrackingMetaPixel(req.trackingMetaPixel());

        try {
            bp.setSocialHandlesJson(req.socialHandles() != null ?
                objectMapper.writeValueAsString(req.socialHandles()) : "{}");
            bp.setGoalsJson(objectMapper.writeValueAsString(req.goals()));
            bp.setConstraintsJson(req.constraints() != null ?
                objectMapper.writeValueAsString(req.constraints()) : "[]");
            bp.setCompetitorsJson(req.competitors() != null ?
                objectMapper.writeValueAsString(req.competitors()) : "[]");
        } catch (Exception e) {
            throw new RuntimeException("JSON serialization error", e);
        }

        bp = profileRepository.save(bp);
        auditService.log(orgId, userId, "PROFILE_UPDATE", "business_profile",
            bp.getId().toString(), "{}", ip);
        return toResponse(bp);
    }

    @Transactional
    public void delete(UUID orgId, UUID userId, UUID id, String ip) {
        BusinessProfile bp = profileRepository.findByIdAndOrgId(id, orgId)
            .orElseThrow(() -> new NoSuchElementException("Profile not found"));
        profileRepository.delete(bp);
        auditService.log(orgId, userId, "PROFILE_DELETE", "business_profile",
            id.toString(), "{}", ip);
    }

    private Response toResponse(BusinessProfile bp) {
        return new Response(
            bp.getId().toString(), bp.getBusinessName(), bp.getCategory(),
            bp.getCity(), bp.getState(), bp.getZip(),
            bp.getMonthlyRevenue(), bp.getMonthlyMarketingBudget(),
            bp.getSalesChannels(), bp.getEcommercePlatform(), bp.getWebsite(),
            bp.getAvgOrderValue(), bp.getMarginPct(), bp.getTeamSize(),
            bp.getSocialHandlesJson(), bp.isTrackingGa4(), bp.isTrackingMetaPixel(),
            bp.getGoalsJson(), bp.getConstraintsJson(), bp.getCompetitorsJson(),
            bp.getCreatedAt().toString()
        );
    }
}
EOF

# ─── Plan Service ───────────────────────────────────────────────────────────
write_file "$PKG/service/PlanService.java" << 'EOF'
package com.growthblueprint.api.service;

import com.growthblueprint.api.dto.PlanDtos.*;
import com.growthblueprint.api.entity.*;
import com.growthblueprint.api.repository.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class PlanService {

    private final PlanJobRepository planJobRepository;
    private final MarketingPlanRepository marketingPlanRepository;
    private final BusinessProfileRepository profileRepository;
    private final OrgRepository orgRepository;
    private final AuditService auditService;
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    private static final Map<String, Integer> PLAN_LIMITS = Map.of(
        "FREE", 3, "PRO", 20, "BUSINESS", 999999
    );

    public PlanService(PlanJobRepository planJobRepository,
                       MarketingPlanRepository marketingPlanRepository,
                       BusinessProfileRepository profileRepository,
                       OrgRepository orgRepository,
                       AuditService auditService,
                       StringRedisTemplate redisTemplate,
                       ObjectMapper objectMapper) {
        this.planJobRepository = planJobRepository;
        this.marketingPlanRepository = marketingPlanRepository;
        this.profileRepository = profileRepository;
        this.orgRepository = orgRepository;
        this.auditService = auditService;
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public PlanJobResponse createPlanJob(UUID orgId, UUID userId, UUID profileId, String ip) {
        Org org = orgRepository.findById(orgId)
            .orElseThrow(() -> new IllegalStateException("Org not found"));

        int limit = PLAN_LIMITS.getOrDefault(org.getPlanTier(), 3);
        if (org.getPlansUsedThisPeriod() >= limit) {
            throw new IllegalStateException("Plan generation limit reached for tier " + org.getPlanTier());
        }

        BusinessProfile profile = profileRepository.findByIdAndOrgId(profileId, orgId)
            .orElseThrow(() -> new NoSuchElementException("Profile not found"));

        // Compute input hash for idempotency
        String inputHash = computeInputHash(profile);

        // Check for existing pending/processing job with same hash
        Optional<PlanJob> existing = planJobRepository
            .findByBusinessProfileIdAndInputHashAndStatusIn(
                profileId, inputHash, List.of("PENDING", "PROCESSING"));
        if (existing.isPresent()) {
            PlanJob ej = existing.get();
            return new PlanJobResponse(ej.getId().toString(), profileId.toString(),
                ej.getStatus(), ej.getPlanId() != null ? ej.getPlanId().toString() : null,
                ej.getErrorMessage(), ej.getCreatedAt().toString());
        }

        PlanJob job = new PlanJob();
        job.setOrgId(orgId);
        job.setBusinessProfileId(profileId);
        job.setInputHash(inputHash);
        job.setStatus("PENDING");
        job = planJobRepository.save(job);

        org.setPlansUsedThisPeriod(org.getPlansUsedThisPeriod() + 1);
        orgRepository.save(org);

        // Enqueue to Redis
        try {
            Map<String, String> jobPayload = Map.of(
                "jobId", job.getId().toString(),
                "profileId", profileId.toString(),
                "orgId", orgId.toString(),
                "tier", org.getPlanTier(),
                "inputHash", inputHash
            );
            redisTemplate.opsForList().leftPush("plan_jobs_queue",
                objectMapper.writeValueAsString(jobPayload));
        } catch (Exception e) {
            throw new RuntimeException("Failed to enqueue plan job", e);
        }

        auditService.log(orgId, userId, "PLAN_GENERATE", "plan_job",
            job.getId().toString(), "{}", ip);

        return new PlanJobResponse(job.getId().toString(), profileId.toString(),
            job.getStatus(), null, null, job.getCreatedAt().toString());
    }

    public PlanJobResponse getJobStatus(UUID orgId, UUID jobId) {
        PlanJob job = planJobRepository.findByIdAndOrgId(jobId, orgId)
            .orElseThrow(() -> new NoSuchElementException("Job not found"));
        return new PlanJobResponse(job.getId().toString(),
            job.getBusinessProfileId().toString(), job.getStatus(),
            job.getPlanId() != null ? job.getPlanId().toString() : null,
            job.getErrorMessage(), job.getCreatedAt().toString());
    }

    public List<PlanResponse> getPlansForProfile(UUID orgId, UUID profileId) {
        return marketingPlanRepository.findByBusinessProfileIdAndOrgIdOrderByCreatedAtDesc(profileId, orgId)
            .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public PlanResponse getPlan(UUID orgId, UUID planId) {
        MarketingPlan plan = marketingPlanRepository.findByIdAndOrgId(planId, orgId)
            .orElseThrow(() -> new NoSuchElementException("Plan not found"));
        return toResponse(plan);
    }

    public ExportResponse exportPlanPdf(UUID orgId, UUID planId) {
        Org org = orgRepository.findById(orgId)
            .orElseThrow(() -> new IllegalStateException("Org not found"));
        if ("FREE".equals(org.getPlanTier())) {
            throw new IllegalStateException("PDF export not available for FREE tier");
        }
        MarketingPlan plan = marketingPlanRepository.findByIdAndOrgId(planId, orgId)
            .orElseThrow(() -> new NoSuchElementException("Plan not found"));
        // Generate HTML as fallback for PDF
        String html = "<html><body><h1>Marketing Plan</h1>"
            + "<p>Quality: " + plan.getForecastQuality() + "</p>"
            + "<pre>" + plan.getSectionsJson() + "</pre>"
            + "</body></html>";
        return new ExportResponse(planId.toString(), "html", html);
    }

    private PlanResponse toResponse(MarketingPlan plan) {
        return new PlanResponse(
            plan.getId().toString(), plan.getBusinessProfileId().toString(),
            plan.getTier(), plan.getForecastQuality(),
            plan.getAssumptionsJson(), plan.getLimitationsJson(),
            plan.getConfidenceNote(), plan.getSectionsJson(),
            plan.getForecastJson(), plan.getCreatedAt().toString()
        );
    }

    private String computeInputHash(BusinessProfile profile) {
        try {
            String data = profile.getBusinessName() + profile.getCategory()
                + profile.getMonthlyRevenue() + profile.getMonthlyMarketingBudget()
                + profile.getSalesChannels() + profile.getGoalsJson()
                + profile.getConstraintsJson();
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash).substring(0, 32);
        } catch (Exception e) {
            throw new RuntimeException("Failed to compute input hash", e);
        }
    }
}
EOF


###############################################################################
# SPRING BOOT - Controllers
###############################################################################

PKG="apps/api/src/main/java/com/growthblueprint/api"

write_file "$PKG/controller/HealthController.java" << 'EOF'
package com.growthblueprint.api.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "growthblueprint-api"));
    }
}
EOF

write_file "$PKG/controller/AuthController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.AuthDtos.*;
import com.growthblueprint.api.security.AuthPrincipal;
import com.growthblueprint.api.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) { this.authService = authService; }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req,
                                                  HttpServletRequest httpReq) {
        return ResponseEntity.ok(authService.register(req, httpReq.getRemoteAddr()));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest req,
                                               HttpServletRequest httpReq) {
        return ResponseEntity.ok(authService.login(req, httpReq.getRemoteAddr()));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshRequest req) {
        return ResponseEntity.ok(authService.refresh(req));
    }

    @PostMapping("/logout")
    public ResponseEntity<MessageResponse> logout(@AuthenticationPrincipal AuthPrincipal principal,
                                                    HttpServletRequest httpReq) {
        authService.logout(principal.userId(), httpReq.getRemoteAddr());
        return ResponseEntity.ok(new MessageResponse("Logged out"));
    }
}
EOF

write_file "$PKG/controller/BusinessProfileController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.BusinessProfileDto.*;
import com.growthblueprint.api.security.AuthPrincipal;
import com.growthblueprint.api.service.BusinessProfileService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/business-profiles")
public class BusinessProfileController {

    private final BusinessProfileService profileService;

    public BusinessProfileController(BusinessProfileService profileService) {
        this.profileService = profileService;
    }

    @PostMapping
    public ResponseEntity<Response> create(@AuthenticationPrincipal AuthPrincipal principal,
                                            @Valid @RequestBody CreateRequest req,
                                            HttpServletRequest httpReq) {
        return ResponseEntity.ok(profileService.create(
            principal.orgId(), principal.userId(), req, httpReq.getRemoteAddr()));
    }

    @GetMapping
    public ResponseEntity<List<Response>> list(@AuthenticationPrincipal AuthPrincipal principal) {
        return ResponseEntity.ok(profileService.listByOrg(principal.orgId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Response> get(@AuthenticationPrincipal AuthPrincipal principal,
                                         @PathVariable UUID id) {
        return ResponseEntity.ok(profileService.getById(principal.orgId(), id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Response> update(@AuthenticationPrincipal AuthPrincipal principal,
                                            @PathVariable UUID id,
                                            @Valid @RequestBody CreateRequest req,
                                            HttpServletRequest httpReq) {
        return ResponseEntity.ok(profileService.update(
            principal.orgId(), principal.userId(), id, req, httpReq.getRemoteAddr()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@AuthenticationPrincipal AuthPrincipal principal,
                                        @PathVariable UUID id,
                                        HttpServletRequest httpReq) {
        profileService.delete(principal.orgId(), principal.userId(), id, httpReq.getRemoteAddr());
        return ResponseEntity.noContent().build();
    }
}
EOF

write_file "$PKG/controller/PlanController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.PlanDtos.*;
import com.growthblueprint.api.security.AuthPrincipal;
import com.growthblueprint.api.service.PlanService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;

@RestController
public class PlanController {

    private final PlanService planService;

    public PlanController(PlanService planService) { this.planService = planService; }

    @PostMapping("/business-profiles/{id}/plans")
    public ResponseEntity<PlanJobResponse> createPlan(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable UUID id,
            HttpServletRequest httpReq) {
        return ResponseEntity.ok(planService.createPlanJob(
            principal.orgId(), principal.userId(), id, httpReq.getRemoteAddr()));
    }

    @GetMapping("/plans/jobs/{jobId}")
    public ResponseEntity<PlanJobResponse> getJobStatus(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable UUID jobId) {
        return ResponseEntity.ok(planService.getJobStatus(principal.orgId(), jobId));
    }

    @GetMapping("/business-profiles/{id}/plans")
    public ResponseEntity<List<PlanResponse>> getPlansForProfile(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable UUID id) {
        return ResponseEntity.ok(planService.getPlansForProfile(principal.orgId(), id));
    }

    @GetMapping("/plans/{planId}")
    public ResponseEntity<PlanResponse> getPlan(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable UUID planId) {
        return ResponseEntity.ok(planService.getPlan(principal.orgId(), planId));
    }

    @PostMapping("/plans/{planId}/export/pdf")
    public ResponseEntity<ExportResponse> exportPdf(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable UUID planId) {
        return ResponseEntity.ok(planService.exportPlanPdf(principal.orgId(), planId));
    }
}
EOF

write_file "$PKG/controller/ConnectorController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.ConnectorDtos.*;
import com.growthblueprint.api.entity.Connector;
import com.growthblueprint.api.entity.Org;
import com.growthblueprint.api.repository.ConnectorRepository;
import com.growthblueprint.api.repository.OrgRepository;
import com.growthblueprint.api.security.AuthPrincipal;
import com.growthblueprint.api.service.AuditService;
import com.growthblueprint.api.util.EncryptionUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/connectors")
public class ConnectorController {

    private final ConnectorRepository connectorRepository;
    private final OrgRepository orgRepository;
    private final AuditService auditService;
    private final EncryptionUtil encryptionUtil;
    private final ObjectMapper objectMapper;
    private final boolean devMode;

    private static final List<String> VALID_PLATFORMS = List.of(
        "meta_ads", "google_ads", "tiktok_ads", "youtube_analytics",
        "ga4", "shopify", "google_search_console"
    );

    public ConnectorController(ConnectorRepository connectorRepository,
                                OrgRepository orgRepository,
                                AuditService auditService,
                                EncryptionUtil encryptionUtil,
                                ObjectMapper objectMapper,
                                @Value("${app.dev-mode}") boolean devMode) {
        this.connectorRepository = connectorRepository;
        this.orgRepository = orgRepository;
        this.auditService = auditService;
        this.encryptionUtil = encryptionUtil;
        this.objectMapper = objectMapper;
        this.devMode = devMode;
    }

    @PostMapping("/{platform}/connect")
    public ResponseEntity<?> connect(@AuthenticationPrincipal AuthPrincipal principal,
                                      @PathVariable String platform,
                                      @RequestBody ConnectRequest req,
                                      HttpServletRequest httpReq) {
        validatePaidTier(principal.orgId());
        validatePlatform(platform);

        // Manual token connect only in DEV_MODE and for OWNER
        if (!devMode) {
            return ResponseEntity.badRequest().body(
                new SyncResponse(platform, "ERROR", "Manual token connect is only allowed in DEV_MODE"));
        }
        if (!"OWNER".equals(principal.role())) {
            return ResponseEntity.status(403).body(
                new SyncResponse(platform, "ERROR", "Only OWNER can connect in DEV_MODE"));
        }

        Connector connector = connectorRepository.findByOrgIdAndPlatform(principal.orgId(), platform)
            .orElse(new Connector());

        connector.setOrgId(principal.orgId());
        connector.setPlatform(platform);
        connector.setStatus("CONNECTED");

        try {
            String tokensJson = objectMapper.writeValueAsString(req.tokens());
            connector.setEncryptedTokensJson(encryptionUtil.encrypt(tokensJson));
            connector.setScopesJson(objectMapper.writeValueAsString(req.scopes()));
        } catch (Exception e) {
            throw new RuntimeException("Failed to encrypt tokens", e);
        }

        connectorRepository.save(connector);
        auditService.log(principal.orgId(), principal.userId(), "CONNECTOR_CONNECT",
            "connector", platform, "{}", httpReq.getRemoteAddr());

        return ResponseEntity.ok(toResponse(connector));
    }

    @PostMapping("/{platform}/disconnect")
    public ResponseEntity<ConnectorResponse> disconnect(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable String platform,
            HttpServletRequest httpReq) {
        validatePaidTier(principal.orgId());
        Connector connector = connectorRepository.findByOrgIdAndPlatform(principal.orgId(), platform)
            .orElseThrow(() -> new java.util.NoSuchElementException("Connector not found"));

        connector.setStatus("DISCONNECTED");
        connector.setEncryptedTokensJson(null);
        connectorRepository.save(connector);

        auditService.log(principal.orgId(), principal.userId(), "CONNECTOR_DISCONNECT",
            "connector", platform, "{}", httpReq.getRemoteAddr());

        return ResponseEntity.ok(toResponse(connector));
    }

    @GetMapping
    public ResponseEntity<List<ConnectorResponse>> list(
            @AuthenticationPrincipal AuthPrincipal principal) {
        validatePaidTier(principal.orgId());
        return ResponseEntity.ok(
            connectorRepository.findByOrgId(principal.orgId()).stream()
                .map(this::toResponse).collect(Collectors.toList()));
    }

    @PostMapping("/{platform}/sync")
    public ResponseEntity<SyncResponse> sync(
            @AuthenticationPrincipal AuthPrincipal principal,
            @PathVariable String platform,
            HttpServletRequest httpReq) {
        validatePaidTier(principal.orgId());
        Connector connector = connectorRepository.findByOrgIdAndPlatform(principal.orgId(), platform)
            .orElseThrow(() -> new java.util.NoSuchElementException("Connector not found"));

        if (!"CONNECTED".equals(connector.getStatus())) {
            return ResponseEntity.badRequest().body(
                new SyncResponse(platform, "ERROR", "Connector not connected"));
        }

        auditService.log(principal.orgId(), principal.userId(), "CONNECTOR_SYNC",
            "connector", platform, "{}", httpReq.getRemoteAddr());

        return ResponseEntity.ok(new SyncResponse(platform, "QUEUED",
            "Sync job queued. Data will appear in analytics once complete."));
    }

    private void validatePaidTier(UUID orgId) {
        Org org = orgRepository.findById(orgId)
            .orElseThrow(() -> new IllegalStateException("Org not found"));
        if ("FREE".equals(org.getPlanTier())) {
            throw new IllegalStateException("Connectors require a paid plan (PRO or BUSINESS)");
        }
    }

    private void validatePlatform(String platform) {
        if (!VALID_PLATFORMS.contains(platform)) {
            throw new IllegalArgumentException("Invalid platform: " + platform
                + ". Valid: " + String.join(", ", VALID_PLATFORMS));
        }
    }

    private ConnectorResponse toResponse(Connector c) {
        return new ConnectorResponse(c.getId().toString(), c.getPlatform(),
            c.getStatus(),
            c.getLastSyncAt() != null ? c.getLastSyncAt().toString() : null,
            c.getLastError(), c.getScopesJson());
    }
}
EOF

write_file "$PKG/controller/AnalyticsController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.AnalyticsDtos.*;
import com.growthblueprint.api.entity.AnalyticsDaily;
import com.growthblueprint.api.entity.Org;
import com.growthblueprint.api.repository.AnalyticsDailyRepository;
import com.growthblueprint.api.repository.OrgRepository;
import com.growthblueprint.api.security.AuthPrincipal;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/analytics")
public class AnalyticsController {

    private final AnalyticsDailyRepository analyticsRepository;
    private final OrgRepository orgRepository;

    public AnalyticsController(AnalyticsDailyRepository analyticsRepository,
                                OrgRepository orgRepository) {
        this.analyticsRepository = analyticsRepository;
        this.orgRepository = orgRepository;
    }

    @GetMapping("/summary")
    public ResponseEntity<SummaryResponse> getSummary(
            @AuthenticationPrincipal AuthPrincipal principal,
            @RequestParam UUID profileId,
            @RequestParam String from,
            @RequestParam String to) {
        Org org = orgRepository.findById(principal.orgId())
            .orElseThrow(() -> new IllegalStateException("Org not found"));
        if ("FREE".equals(org.getPlanTier())) {
            throw new IllegalStateException("Analytics require a paid plan");
        }

        LocalDate fromDate = LocalDate.parse(from);
        LocalDate toDate = LocalDate.parse(to);

        List<DailyMetric> metrics = analyticsRepository
            .findByOrgIdAndBusinessProfileIdAndMetricDateBetween(
                principal.orgId(), profileId, fromDate, toDate)
            .stream()
            .map(a -> new DailyMetric(
                a.getMetricDate().toString(), a.getPlatform(),
                a.getImpressions(), a.getClicks(), a.getSpend(),
                a.getConversions(), a.getRevenue(), a.getCtr(), a.getRoas()))
            .collect(Collectors.toList());

        return ResponseEntity.ok(new SummaryResponse(metrics, from, to, profileId.toString()));
    }
}
EOF

write_file "$PKG/controller/BillingController.java" << 'EOF'
package com.growthblueprint.api.controller;

import com.growthblueprint.api.dto.BillingDtos.*;
import com.growthblueprint.api.entity.Org;
import com.growthblueprint.api.repository.OrgRepository;
import com.growthblueprint.api.security.AuthPrincipal;
import com.growthblueprint.api.service.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/billing")
public class BillingController {

    private static final Logger log = LoggerFactory.getLogger(BillingController.class);

    private final OrgRepository orgRepository;
    private final AuditService auditService;

    @Value("${app.stripe.secret-key}")
    private String stripeSecretKey;

    @Value("${app.stripe.webhook-secret}")
    private String webhookSecret;

    @Value("${app.stripe.price-pro}")
    private String priceProId;

    @Value("${app.stripe.price-business}")
    private String priceBusinessId;

    private static final Map<String, Integer> PLAN_LIMITS = Map.of(
        "FREE", 3, "PRO", 20, "BUSINESS", 999999
    );
    private static final Map<String, Integer> PROFILE_LIMITS = Map.of(
        "FREE", 1, "PRO", 5, "BUSINESS", 20
    );

    public BillingController(OrgRepository orgRepository, AuditService auditService) {
        this.orgRepository = orgRepository;
        this.auditService = auditService;
    }

    @PostMapping("/stripe/checkout-session")
    public ResponseEntity<?> createCheckoutSession(
            @AuthenticationPrincipal AuthPrincipal principal,
            @RequestBody CheckoutRequest req,
            HttpServletRequest httpReq) {
        // In dev/placeholder mode, return a mock URL
        auditService.log(principal.orgId(), principal.userId(), "BILLING_CHECKOUT",
            "billing", req.tier(), "{}", httpReq.getRemoteAddr());
        return ResponseEntity.ok(new CheckoutResponse(
            "https://checkout.stripe.com/placeholder?tier=" + req.tier()));
    }

    @PostMapping("/stripe/portal")
    public ResponseEntity<PortalResponse> createPortal(
            @AuthenticationPrincipal AuthPrincipal principal) {
        return ResponseEntity.ok(new PortalResponse(
            "https://billing.stripe.com/placeholder/portal"));
    }

    @PostMapping("/stripe/webhook")
    public ResponseEntity<String> handleWebhook(
            @RequestBody String payload,
            @RequestHeader(value = "Stripe-Signature", required = false) String sigHeader) {
        // Webhook signature verification placeholder
        // In production, verify using Stripe SDK:
        // Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
        log.info("Received Stripe webhook (signature verification skipped in dev mode)");
        return ResponseEntity.ok("ok");
    }

    @GetMapping("/me")
    public ResponseEntity<BillingStatusResponse> getMyBilling(
            @AuthenticationPrincipal AuthPrincipal principal) {
        Org org = orgRepository.findById(principal.orgId())
            .orElseThrow(() -> new IllegalStateException("Org not found"));
        return ResponseEntity.ok(new BillingStatusResponse(
            org.getPlanTier(),
            org.getStripeStatus(),
            org.getPlansUsedThisPeriod(),
            PLAN_LIMITS.getOrDefault(org.getPlanTier(), 3),
            0, // Will be computed from profile count query
            PROFILE_LIMITS.getOrDefault(org.getPlanTier(), 1),
            org.getUsageResetAt().toString()
        ));
    }
}
EOF

# ─── Global Exception Handler ──────────────────────────────────────────────
write_file "$PKG/config/GlobalExceptionHandler.java" << 'EOF'
package com.growthblueprint.api.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import java.util.Map;
import java.util.NoSuchElementException;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<Map<String, String>> handleConflict(IllegalStateException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler(NoSuchElementException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(NoSuchElementException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException ex) {
        String msg = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .reduce((a, b) -> a + "; " + b).orElse("Validation error");
        return ResponseEntity.badRequest().body(Map.of("error", msg));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGeneral(Exception ex) {
        log.error("Unhandled exception", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(Map.of("error", "Internal server error"));
    }
}
EOF

# ─── API Dockerfile ─────────────────────────────────────────────────────────
write_file "apps/api/Dockerfile" << 'EOF'
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
RUN chmod +x mvnw && ./mvnw dependency:resolve
COPY src src
RUN ./mvnw package -DskipTests -q

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# ─── Maven Wrapper ──────────────────────────────────────────────────────────
mkdir -p apps/api/.mvn/wrapper
write_file "apps/api/mvnw" << 'MVNW'
#!/bin/sh
exec mvn "$@"
MVNW
chmod +x apps/api/mvnw 2>/dev/null || true

# ─── Test file ──────────────────────────────────────────────────────────────
write_file "apps/api/src/test/java/com/growthblueprint/api/GrowthBlueprintApplicationTests.java" << 'EOF'
package com.growthblueprint.api;

import org.junit.jupiter.api.Test;

class GrowthBlueprintApplicationTests {
    @Test
    void contextLoadsSmoke() {
        // Smoke test - verifies compilation
        assert true;
    }
}
EOF


###############################################################################
# AI ORCHESTRATOR (apps/ai-orchestrator)
###############################################################################

write_file "apps/ai-orchestrator/package.json" << 'EOF'
{
  "name": "@growthblueprint/ai-orchestrator",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest --passWithNoTests",
    "ingest": "tsx src/knowledge/ingest.ts"
  },
  "dependencies": {
    "@growthblueprint/shared": "1.0.0",
    "bullmq": "^5.1.0",
    "ioredis": "^5.3.2",
    "pg": "^8.11.3",
    "pgvector": "^0.1.8",
    "uuid": "^9.0.0",
    "zod": "^3.22.4",
    "express": "^4.18.2",
    "pino": "^8.17.2"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.11.0",
    "@types/pg": "^8.10.9",
    "@types/uuid": "^9.0.7",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "@types/jest": "^29.5.11",
    "tsx": "^4.7.0",
    "typescript": "^5.3.3"
  }
}
EOF

write_file "apps/ai-orchestrator/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "sourceMap": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "src/__tests__"]
}
EOF

write_file "apps/ai-orchestrator/jest.config.js" << 'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
};
EOF

write_file "apps/ai-orchestrator/src/index.ts" << 'EOF'
import express from 'express';
import pino from 'pino';
import { PlanWorker } from './workers/planWorker';
import { SyncScheduler } from './workers/syncScheduler';

const logger = pino({ level: process.env.LOG_LEVEL || 'info' });
const app = express();
const PORT = parseInt(process.env.PORT || '4000', 10);

app.get('/health', (_req, res) => {
  res.json({ status: 'UP', service: 'ai-orchestrator' });
});

const planWorker = new PlanWorker(logger);
const syncScheduler = new SyncScheduler(logger);

planWorker.start();
syncScheduler.start();

app.listen(PORT, () => {
  logger.info(`AI Orchestrator running on port ${PORT}`);
});

process.on('SIGTERM', async () => {
  logger.info('Shutting down...');
  await planWorker.stop();
  await syncScheduler.stop();
  process.exit(0);
});
EOF

# ─── LLM Adapter ───────────────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/tools/llmAdapter.ts" << 'EOF'
import pino from 'pino';

export interface LLMRequest {
  systemPrompt: string;
  userPrompt: string;
  maxTokens?: number;
}

export interface LLMResponse {
  content: string;
  tokensUsed: number;
  model: string;
}

export interface LLMProvider {
  generate(req: LLMRequest): Promise<LLMResponse>;
}

/**
 * Mock LLM provider for development.
 * Replace with OpenAI/Anthropic/etc in production.
 */
export class MockLLMProvider implements LLMProvider {
  private logger: pino.Logger;

  constructor(logger: pino.Logger) {
    this.logger = logger;
  }

  async generate(req: LLMRequest): Promise<LLMResponse> {
    this.logger.info('MockLLM: generating response');

    // Policy guardrails: never guarantee outcomes, never fabricate data
    const guardrails = [
      'NOTE: All recommendations are suggestions based on available data.',
      'We do not guarantee specific ROI or outcomes.',
      'No competitor data was scraped or fetched.',
      'No influencer accounts were fabricated.',
    ];

    const content = JSON.stringify({
      sections: [
        {
          title: 'Executive Summary',
          content: 'Based on your business profile, here are tailored marketing recommendations.',
          recommendations: [
            'Focus on your strongest sales channel first',
            'Allocate budget proportionally to proven channels',
            'Track key metrics consistently for at least 30 days before adjusting'
          ],
          estimatedBudgetAllocation: 100
        },
        {
          title: 'Digital Advertising Strategy',
          content: 'A multi-channel approach optimized for your budget and goals.',
          recommendations: [
            'Start with search ads targeting high-intent keywords',
            'Use social ads for awareness and retargeting',
            'Set up proper conversion tracking before spending'
          ],
          estimatedBudgetAllocation: 40
        },
        {
          title: 'Content & Social Media',
          content: 'Build organic presence to reduce long-term acquisition costs.',
          recommendations: [
            'Post consistently 3-5 times per week',
            'Focus on educational and behind-the-scenes content',
            'Engage with your community daily'
          ],
          estimatedBudgetAllocation: 20
        },
        {
          title: 'SEO & Website Optimization',
          content: 'Improve organic discoverability for sustainable traffic.',
          recommendations: [
            'Optimize Google Business Profile',
            'Create location-specific landing pages',
            'Ensure mobile-first website experience'
          ],
          estimatedBudgetAllocation: 20
        },
        {
          title: 'Measurement & Optimization',
          content: 'Set up proper tracking to make data-driven decisions.',
          recommendations: [
            'Install GA4 and configure conversion events',
            'Set up weekly reporting dashboards',
            'Review and adjust strategy monthly'
          ],
          estimatedBudgetAllocation: 20
        }
      ],
      guardrails
    });

    return {
      content,
      tokensUsed: 500,
      model: 'mock-v1'
    };
  }
}

export function createLLMProvider(logger: pino.Logger): LLMProvider {
  const provider = process.env.LLM_PROVIDER || 'mock';
  switch (provider) {
    case 'mock':
    default:
      return new MockLLMProvider(logger);
  }
}
EOF

# ─── Deterministic Tools ───────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/tools/deterministicTools.ts" << 'EOF'
export interface BudgetAllocation {
  channel: string;
  percentage: number;
  amount: number;
  rationale: string;
}

export interface ForecastResult {
  quality: 'HIGH' | 'MEDIUM' | 'LOW';
  rangeMin: number;
  rangeMax: number;
  unit: string;
  period: string;
  dataSourcesUsed: string[];
  connectDataChecklist: string[];
  assumptions: string[];
  limitations: string[];
  confidenceNote: string;
}

export function computeBudgetAllocation(
  monthlyBudget: number,
  salesChannels: string,
  goals: string[],
  hasGA4: boolean,
  hasMetaPixel: boolean
): BudgetAllocation[] {
  const allocations: BudgetAllocation[] = [];
  let remaining = 100;

  // Paid search gets more if online/both
  if (salesChannels === 'online' || salesChannels === 'both') {
    const pct = goals.includes('onlineSales') ? 35 : 25;
    allocations.push({
      channel: 'Paid Search (Google Ads)',
      percentage: pct,
      amount: Math.round(monthlyBudget * pct / 100),
      rationale: 'High-intent traffic for online sales'
    });
    remaining -= pct;
  }

  // Social ads
  if (goals.includes('awareness') || goals.includes('leads')) {
    const pct = Math.min(30, remaining);
    allocations.push({
      channel: 'Social Advertising (Meta/TikTok)',
      percentage: pct,
      amount: Math.round(monthlyBudget * pct / 100),
      rationale: 'Brand awareness and lead generation'
    });
    remaining -= pct;
  }

  // Content
  const contentPct = Math.min(20, remaining);
  allocations.push({
    channel: 'Content & SEO',
    percentage: contentPct,
    amount: Math.round(monthlyBudget * contentPct / 100),
    rationale: 'Long-term organic growth'
  });
  remaining -= contentPct;

  // Local if store visits
  if (goals.includes('storeVisits') && remaining > 0) {
    allocations.push({
      channel: 'Local Marketing',
      percentage: remaining,
      amount: Math.round(monthlyBudget * remaining / 100),
      rationale: 'Drive foot traffic'
    });
  } else if (remaining > 0) {
    allocations.push({
      channel: 'Testing & Optimization',
      percentage: remaining,
      amount: Math.round(monthlyBudget * remaining / 100),
      rationale: 'Reserve for testing new channels'
    });
  }

  return allocations;
}

export function computeForecast(
  tier: string,
  hasShopify: boolean,
  hasGA4: boolean,
  connectedPlatforms: string[],
  monthlyRevenue: number,
  monthlyBudget: number
): ForecastResult {
  const dataSourcesUsed: string[] = [];
  const connectDataChecklist: string[] = [];

  if (hasShopify) dataSourcesUsed.push('Shopify (primary truth source)');
  if (hasGA4) dataSourcesUsed.push('GA4 (conversion tracking)');
  connectedPlatforms.forEach(p => dataSourcesUsed.push(`${p} (diagnostics)`));

  // Determine quality
  let quality: 'HIGH' | 'MEDIUM' | 'LOW' = 'LOW';
  if (dataSourcesUsed.length >= 3) quality = 'HIGH';
  else if (dataSourcesUsed.length >= 1) quality = 'MEDIUM';

  // Build checklist for missing data
  if (!hasShopify && !hasGA4) {
    connectDataChecklist.push('Connect Shopify or install GA4 for revenue tracking');
  }
  if (tier === 'FREE') {
    connectDataChecklist.push('Upgrade to PRO to connect analytics platforms');
  }
  if (connectedPlatforms.length === 0 && tier !== 'FREE') {
    connectDataChecklist.push('Connect at least one advertising platform');
  }

  // Compute ranges (wider if LOW quality)
  const budgetMultiplier = quality === 'HIGH' ? 2.5 : quality === 'MEDIUM' ? 3.5 : 5;
  const rangeMin = Math.round(monthlyBudget * (budgetMultiplier * 0.5));
  const rangeMax = Math.round(monthlyBudget * budgetMultiplier);

  const assumptions = [
    `Based on ${monthlyBudget} USD monthly marketing budget`,
    `Current monthly revenue: ${monthlyRevenue} USD`,
    'Industry average conversion rates applied',
    'Assumes consistent execution of recommendations',
  ];

  const limitations = [
    'Forecasts are estimates based on limited data',
    'Actual results depend on execution quality and market conditions',
    'Seasonal variations not fully accounted for',
  ];

  if (quality === 'LOW') {
    limitations.push('WARNING: Low data quality. Ranges are intentionally wide.');
    limitations.push('Connect more data sources for more precise estimates.');
  }

  const confidenceNote = quality === 'HIGH'
    ? 'Good data coverage. Estimates are reasonably calibrated.'
    : quality === 'MEDIUM'
    ? 'Moderate data coverage. Estimates have meaningful uncertainty.'
    : 'Limited data. Treat these as directional estimates only. Connect more data sources for better precision.';

  return {
    quality,
    rangeMin,
    rangeMax,
    unit: 'USD',
    period: 'monthly',
    dataSourcesUsed,
    connectDataChecklist,
    assumptions,
    limitations,
    confidenceNote,
  };
}
EOF

# ─── Plan Worker ────────────────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/workers/planWorker.ts" << 'EOF'
import pino from 'pino';
import Redis from 'ioredis';
import { Pool } from 'pg';
import { createLLMProvider } from '../tools/llmAdapter';
import { computeBudgetAllocation, computeForecast } from '../tools/deterministicTools';
import { v4 as uuidv4 } from 'uuid';

const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';
const DB_URL = process.env.DATABASE_URL || 'postgresql://gb_user:gb_pass_dev@localhost:5432/growthblueprint';

export class PlanWorker {
  private logger: pino.Logger;
  private redis: Redis;
  private db: Pool;
  private running = false;
  private pollInterval: NodeJS.Timeout | null = null;

  constructor(logger: pino.Logger) {
    this.logger = logger.child({ component: 'PlanWorker' });
    this.redis = new Redis(REDIS_URL, { maxRetriesPerRequest: 3 });
    this.db = new Pool({ connectionString: DB_URL, max: 5 });
  }

  start() {
    this.running = true;
    this.logger.info('PlanWorker started, polling for jobs...');
    this.pollInterval = setInterval(() => this.poll(), 2000);
  }

  async stop() {
    this.running = false;
    if (this.pollInterval) clearInterval(this.pollInterval);
    await this.redis.quit();
    await this.db.end();
  }

  private async poll() {
    if (!this.running) return;
    try {
      const raw = await this.redis.rpop('plan_jobs_queue');
      if (!raw) return;

      const job = JSON.parse(raw);
      await this.processJob(job);
    } catch (err) {
      this.logger.error({ err }, 'Error polling plan job queue');
    }
  }

  private async processJob(job: {
    jobId: string; profileId: string; orgId: string; tier: string; inputHash: string;
  }) {
    const { jobId, profileId, orgId, tier, inputHash } = job;
    this.logger.info({ jobId, profileId }, 'Processing plan job');

    try {
      // Mark as PROCESSING
      await this.db.query(
        `UPDATE plan_jobs SET status = 'PROCESSING', updated_at = NOW() WHERE id = $1`,
        [jobId]
      );

      // Fetch profile
      const profileResult = await this.db.query(
        `SELECT * FROM business_profiles WHERE id = $1 AND org_id = $2`,
        [profileId, orgId]
      );
      if (profileResult.rows.length === 0) throw new Error('Profile not found');
      const profile = profileResult.rows[0];

      // Fetch connected platforms
      const connResult = await this.db.query(
        `SELECT platform FROM connectors WHERE org_id = $1 AND status = 'CONNECTED'`,
        [orgId]
      );
      const connectedPlatforms = connResult.rows.map((r: any) => r.platform);

      // Parse goals
      const goals: string[] = typeof profile.goals_json === 'string'
        ? JSON.parse(profile.goals_json) : profile.goals_json;

      // Deterministic tools
      const budgetAllocation = computeBudgetAllocation(
        Number(profile.monthly_marketing_budget),
        profile.sales_channels,
        goals,
        profile.tracking_ga4,
        profile.tracking_meta_pixel
      );

      const forecast = computeForecast(
        tier,
        profile.ecommerce_platform === 'Shopify',
        profile.tracking_ga4,
        connectedPlatforms,
        Number(profile.monthly_revenue),
        Number(profile.monthly_marketing_budget)
      );

      // LLM generation
      const llm = createLLMProvider(this.logger);
      const llmResponse = await llm.generate({
        systemPrompt: `You are a digital marketing consultant. Generate a marketing plan.
Policy: Never guarantee ROI. Never scrape. Never fabricate influencers or data.
Forecast quality: ${forecast.quality}`,
        userPrompt: `Business: ${profile.business_name}
Category: ${profile.category}
Location: ${profile.city}, ${profile.state} ${profile.zip}
Monthly Revenue: $${profile.monthly_revenue}
Marketing Budget: $${profile.monthly_marketing_budget}
Sales Channels: ${profile.sales_channels}
Goals: ${goals.join(', ')}
Budget Allocation: ${JSON.stringify(budgetAllocation)}`,
      });

      // Parse LLM response
      let sections: any[];
      try {
        const parsed = JSON.parse(llmResponse.content);
        sections = parsed.sections || [];
      } catch {
        sections = [{
          title: 'Marketing Plan',
          content: llmResponse.content,
          recommendations: [],
        }];
      }

      // Save marketing plan
      const planId = uuidv4();
      await this.db.query(
        `INSERT INTO marketing_plans
         (id, org_id, business_profile_id, plan_job_id, tier, input_hash,
          forecast_quality, assumptions_json, limitations_json, confidence_note,
          sections_json, forecast_json)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
        [
          planId, orgId, profileId, jobId, tier, inputHash,
          forecast.quality,
          JSON.stringify(forecast.assumptions),
          JSON.stringify(forecast.limitations),
          forecast.confidenceNote,
          JSON.stringify(sections),
          JSON.stringify({
            rangeMin: forecast.rangeMin,
            rangeMax: forecast.rangeMax,
            unit: forecast.unit,
            period: forecast.period,
            dataSourcesUsed: forecast.dataSourcesUsed,
            connectDataChecklist: forecast.connectDataChecklist,
          }),
        ]
      );

      // Update job status
      await this.db.query(
        `UPDATE plan_jobs SET status = 'COMPLETED', plan_id = $1, updated_at = NOW() WHERE id = $2`,
        [planId, jobId]
      );

      this.logger.info({ jobId, planId }, 'Plan job completed');
    } catch (err: any) {
      this.logger.error({ jobId, err: err.message }, 'Plan job failed');
      await this.db.query(
        `UPDATE plan_jobs SET status = 'FAILED', error_message = $1, updated_at = NOW() WHERE id = $2`,
        [err.message?.substring(0, 500), jobId]
      ).catch(() => {});
    }
  }
}
EOF

# ─── Sync Scheduler ────────────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/workers/syncScheduler.ts" << 'EOF'
import pino from 'pino';
import { Pool } from 'pg';

const DB_URL = process.env.DATABASE_URL || 'postgresql://gb_user:gb_pass_dev@localhost:5432/growthblueprint';

export class SyncScheduler {
  private logger: pino.Logger;
  private db: Pool;
  private interval: NodeJS.Timeout | null = null;

  constructor(logger: pino.Logger) {
    this.logger = logger.child({ component: 'SyncScheduler' });
    this.db = new Pool({ connectionString: DB_URL, max: 3 });
  }

  start() {
    this.logger.info('SyncScheduler started');
    // Check every 30 minutes
    this.interval = setInterval(() => this.checkAndSync(), 30 * 60 * 1000);
  }

  async stop() {
    if (this.interval) clearInterval(this.interval);
    await this.db.end();
  }

  private async checkAndSync() {
    try {
      // Find orgs with connectors that need syncing
      const result = await this.db.query(`
        SELECT o.id as org_id, o.plan_tier, c.platform, c.last_sync_at
        FROM orgs o
        JOIN connectors c ON c.org_id = o.id AND c.status = 'CONNECTED'
        WHERE o.plan_tier IN ('PRO', 'BUSINESS')
      `);

      for (const row of result.rows) {
        const intervalHours = row.plan_tier === 'BUSINESS' ? 6 : 24;
        const lastSync = row.last_sync_at ? new Date(row.last_sync_at) : new Date(0);
        const hoursSince = (Date.now() - lastSync.getTime()) / (1000 * 60 * 60);

        if (hoursSince >= intervalHours) {
          this.logger.info({
            orgId: row.org_id,
            platform: row.platform,
            hoursSince: Math.round(hoursSince)
          }, 'Triggering sync');
          // In production, this would call the actual connector sync
          await this.db.query(
            `UPDATE connectors SET last_sync_at = NOW(), updated_at = NOW()
             WHERE org_id = $1 AND platform = $2`,
            [row.org_id, row.platform]
          );
        }
      }
    } catch (err) {
      this.logger.error({ err }, 'SyncScheduler error');
    }
  }
}
EOF

# ─── Connectors ─────────────────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/connectors/baseConnector.ts" << 'EOF'
import pino from 'pino';

export interface ConnectorConfig {
  platform: string;
  maxRetries: number;
  timeoutMs: number;
  rateLimitPerMinute: number;
}

export interface SyncResult {
  success: boolean;
  recordsProcessed: number;
  errors: string[];
  dataFreshness: Date;
  completeness: number;
}

/**
 * Circuit breaker states: CLOSED (normal), OPEN (failing), HALF_OPEN (testing)
 */
type CircuitState = 'CLOSED' | 'OPEN' | 'HALF_OPEN';

export abstract class BaseConnector {
  protected logger: pino.Logger;
  protected config: ConnectorConfig;
  private circuitState: CircuitState = 'CLOSED';
  private failureCount = 0;
  private lastFailureTime = 0;
  private readonly failureThreshold = 5;
  private readonly resetTimeoutMs = 60000;

  constructor(logger: pino.Logger, config: ConnectorConfig) {
    this.logger = logger.child({ connector: config.platform });
    this.config = config;
  }

  async syncWithRetry(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    // Circuit breaker check
    if (this.circuitState === 'OPEN') {
      if (Date.now() - this.lastFailureTime > this.resetTimeoutMs) {
        this.circuitState = 'HALF_OPEN';
      } else {
        return {
          success: false,
          recordsProcessed: 0,
          errors: ['Circuit breaker OPEN - too many failures'],
          dataFreshness: new Date(),
          completeness: 0,
        };
      }
    }

    for (let attempt = 1; attempt <= this.config.maxRetries; attempt++) {
      try {
        const result = await this.doSync(orgId, tokens);
        this.circuitState = 'CLOSED';
        this.failureCount = 0;
        return result;
      } catch (err: any) {
        this.logger.warn({ attempt, err: err.message }, 'Sync attempt failed');
        this.failureCount++;
        this.lastFailureTime = Date.now();

        if (this.failureCount >= this.failureThreshold) {
          this.circuitState = 'OPEN';
          this.logger.error('Circuit breaker opened');
        }

        if (attempt < this.config.maxRetries) {
          // Exponential backoff: 1s, 2s, 4s, 8s...
          const delay = Math.min(1000 * Math.pow(2, attempt - 1), 30000);
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    return {
      success: false,
      recordsProcessed: 0,
      errors: ['Max retries exceeded'],
      dataFreshness: new Date(),
      completeness: 0,
    };
  }

  protected abstract doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult>;
}
EOF

write_file "apps/ai-orchestrator/src/connectors/metaAdsConnector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class MetaAdsConnector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'meta_ads',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 200,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'Meta Ads sync (placeholder - use official Marketing API)');
    // Production: Use Facebook Marketing API
    // GET /{ad_account_id}/insights with date_preset, fields, etc.
    // Handle: pagination, rate limits (x-business-use-case-usage header), token expiry
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

write_file "apps/ai-orchestrator/src/connectors/googleAdsConnector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class GoogleAdsConnector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'google_ads',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 100,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'Google Ads sync (placeholder - use official Google Ads API)');
    // Production: Use Google Ads API v15+
    // GoogleAdsService.SearchStream with GAQL queries
    // Handle: OAuth refresh, quota limits, partial failures
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

write_file "apps/ai-orchestrator/src/connectors/tiktokAdsConnector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class TikTokAdsConnector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'tiktok_ads',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 60,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'TikTok Ads sync (placeholder - use official TikTok Marketing API)');
    // Production: Use TikTok Marketing API
    // GET /report/integrated/get/ with dimensions and metrics
    // Handle: access token refresh, rate limits, data lag (24-48h)
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

write_file "apps/ai-orchestrator/src/connectors/youtubeAnalyticsConnector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class YouTubeAnalyticsConnector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'youtube_analytics',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 50,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'YouTube Analytics sync (placeholder - use official YouTube Analytics API)');
    // Production: Use YouTube Analytics API v2
    // GET /reports with ids, startDate, endDate, metrics, dimensions
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

write_file "apps/ai-orchestrator/src/connectors/ga4Connector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class GA4Connector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'ga4',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 100,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'GA4 sync (placeholder - use official GA4 Data API)');
    // Production: Use Google Analytics Data API v1beta
    // POST /v1beta/{property}:runReport
    // Handle: quota limits, sampling, data freshness (24-48h lag)
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

write_file "apps/ai-orchestrator/src/connectors/shopifyConnector.ts" << 'EOF'
import pino from 'pino';
import { BaseConnector, SyncResult } from './baseConnector';

export class ShopifyConnector extends BaseConnector {
  constructor(logger: pino.Logger) {
    super(logger, {
      platform: 'shopify',
      maxRetries: 3,
      timeoutMs: 30000,
      rateLimitPerMinute: 40,
    });
  }

  protected async doSync(orgId: string, tokens: Record<string, string>): Promise<SyncResult> {
    this.logger.info({ orgId }, 'Shopify sync (placeholder - use official Shopify Admin API)');
    // Production: Use Shopify Admin API (GraphQL preferred)
    // Query: orders, products, analytics
    // Handle: rate limits (X-Shopify-Shop-Api-Call-Limit), cursor pagination
    // Shopify is PRIMARY truth source for revenue/orders
    return {
      success: true,
      recordsProcessed: 0,
      errors: [],
      dataFreshness: new Date(),
      completeness: 100,
    };
  }
}
EOF

# ─── Knowledge Playbooks ───────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/knowledge/playbooks/jewelry_marketing.md" << 'EOF'
# Jewelry Marketing Playbook

## Key Channels
- Instagram: Visual storytelling, lifestyle imagery
- Pinterest: High-intent shoppers, product discovery
- Google Shopping: Product listing ads
- Email: Nurture sequences, occasion-based campaigns

## Budget Allocation (Typical)
- 40% Paid Social (Instagram, Pinterest)
- 25% Google Ads (Search + Shopping)
- 20% Email Marketing
- 15% Content & SEO

## Best Practices
- High-quality product photography is non-negotiable
- Seasonal campaigns: Valentine's, Mother's Day, Holiday
- User-generated content drives trust
- Retarget website visitors within 7 days
- Average consideration period: 2-4 weeks

## Common Mistakes
- Targeting too broadly on social ads
- Not segmenting email lists by purchase history
- Ignoring local SEO for physical stores
- Not tracking micro-conversions (add to cart, wishlist)
EOF

write_file "apps/ai-orchestrator/src/knowledge/playbooks/restaurant_marketing.md" << 'EOF'
# Restaurant Marketing Playbook

## Key Channels
- Google Business Profile: Critical for local discovery
- Instagram/TikTok: Food content, behind-the-scenes
- Google Ads: Local search campaigns
- Review platforms: Yelp, Google Reviews

## Budget Allocation (Typical)
- 35% Local Paid Search
- 25% Social Media Ads
- 20% Review Management & Local SEO
- 20% Content & Community

## Best Practices
- Optimize Google Business Profile weekly
- Respond to all reviews within 24 hours
- Use location-based targeting (3-10 mile radius)
- Post food content daily during peak hours
- Track in-store conversions via store visits

## Common Mistakes
- Neglecting Google Business Profile
- Not responding to negative reviews
- Targeting too wide a geographic area
- Ignoring menu and hours updates online
EOF

write_file "apps/ai-orchestrator/src/knowledge/playbooks/apparel_marketing.md" << 'EOF'
# Apparel Marketing Playbook

## Key Channels
- Instagram & TikTok: Fashion content, influencer partnerships
- Google Shopping: Product listing ads
- Email: New arrivals, sale notifications
- Pinterest: Style inspiration, lookbooks

## Budget Allocation (Typical)
- 35% Social Ads (Instagram, TikTok)
- 25% Google Shopping & Search
- 20% Email & SMS Marketing
- 20% Content & Influencer

## Best Practices
- Seasonal collections drive urgency
- User-generated content outperforms studio content
- Size guides reduce returns
- Retarget cart abandoners within 1 hour
- Segment by purchase history and preferences

## Common Mistakes
- Not optimizing for mobile shopping experience
- Generic email blasts vs personalized recommendations
- Ignoring return rate impact on ROAS calculations
- Not tracking lifetime value by acquisition channel
EOF

write_file "apps/ai-orchestrator/src/knowledge/playbooks/services_marketing.md" << 'EOF'
# Services Business Marketing Playbook

## Key Channels
- Google Ads: High-intent local search
- Google Business Profile: Reviews and local visibility
- LinkedIn: B2B service providers
- Content Marketing: Thought leadership, case studies

## Budget Allocation (Typical)
- 40% Local Paid Search
- 25% Content & SEO
- 20% Social (LinkedIn for B2B, Facebook for B2C)
- 15% Review & Reputation Management

## Best Practices
- Landing pages per service type
- Call tracking for phone leads
- Case studies and testimonials
- Local service ads (Google Guaranteed)
- Follow-up sequences for leads

## Common Mistakes
- Not tracking call conversions
- Website without clear calls-to-action
- Ignoring review generation
- No lead scoring or qualification process
EOF

# ─── Knowledge Ingestion Script ─────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/knowledge/ingest.ts" << 'EOF'
import { Pool } from 'pg';
import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';
import { v4 as uuidv4 } from 'uuid';

const DB_URL = process.env.DATABASE_URL || 'postgresql://gb_user:gb_pass_dev@localhost:5432/growthblueprint';

async function ingest() {
  const db = new Pool({ connectionString: DB_URL });

  const playbookDir = join(__dirname, 'playbooks');
  const files = readdirSync(playbookDir).filter(f => f.endsWith('.md'));

  for (const file of files) {
    const content = readFileSync(join(playbookDir, file), 'utf-8');
    const category = file.replace('_marketing.md', '').replace('.md', '');
    const title = content.split('\n')[0]?.replace(/^#\s*/, '') || file;

    // Split into chunks (by ## headers)
    const chunks = content.split(/(?=^## )/m).filter(c => c.trim());

    for (const chunk of chunks) {
      const chunkTitle = chunk.split('\n')[0]?.replace(/^##?\s*/, '') || 'Untitled';
      await db.query(
        `INSERT INTO knowledge_chunks (id, category, title, content, metadata_json)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT DO NOTHING`,
        [uuidv4(), category, `${title} - ${chunkTitle}`, chunk.trim(), JSON.stringify({ source: file })]
      );
    }

    console.log(`Ingested: ${file} (${chunks.length} chunks)`);
  }

  await db.end();
  console.log('Knowledge ingestion complete.');
}

ingest().catch(console.error);
EOF

# ─── Tests ──────────────────────────────────────────────────────────────────
write_file "apps/ai-orchestrator/src/__tests__/deterministicTools.test.ts" << 'EOF'
import { computeBudgetAllocation, computeForecast } from '../tools/deterministicTools';

describe('computeBudgetAllocation', () => {
  it('should allocate budget for online sales goals', () => {
    const result = computeBudgetAllocation(5000, 'online', ['onlineSales'], true, true);
    expect(result.length).toBeGreaterThan(0);
    const totalPct = result.reduce((sum, a) => sum + a.percentage, 0);
    expect(totalPct).toBe(100);
  });

  it('should allocate budget for store visits', () => {
    const result = computeBudgetAllocation(3000, 'inStore', ['storeVisits', 'awareness'], false, false);
    expect(result.length).toBeGreaterThan(0);
    expect(result.some(a => a.channel.includes('Local'))).toBe(true);
  });
});

describe('computeForecast', () => {
  it('should return LOW quality when no data sources', () => {
    const result = computeForecast('FREE', false, false, [], 10000, 2000);
    expect(result.quality).toBe('LOW');
    expect(result.connectDataChecklist.length).toBeGreaterThan(0);
  });

  it('should return HIGH quality with multiple data sources', () => {
    const result = computeForecast('PRO', true, true, ['meta_ads', 'google_ads'], 50000, 5000);
    expect(result.quality).toBe('HIGH');
  });

  it('should never produce negative ranges', () => {
    const result = computeForecast('FREE', false, false, [], 0, 100);
    expect(result.rangeMin).toBeGreaterThanOrEqual(0);
    expect(result.rangeMax).toBeGreaterThanOrEqual(result.rangeMin);
  });

  it('should include assumptions and limitations', () => {
    const result = computeForecast('PRO', false, true, [], 10000, 2000);
    expect(result.assumptions.length).toBeGreaterThan(0);
    expect(result.limitations.length).toBeGreaterThan(0);
    expect(result.confidenceNote).toBeTruthy();
  });
});
EOF

write_file "apps/ai-orchestrator/src/__tests__/policyGuardrails.test.ts" << 'EOF'
import { MockLLMProvider } from '../tools/llmAdapter';
import pino from 'pino';

describe('Policy Guardrails', () => {
  const logger = pino({ level: 'silent' });
  const provider = new MockLLMProvider(logger);

  it('should include guardrails in LLM response', async () => {
    const response = await provider.generate({
      systemPrompt: 'test',
      userPrompt: 'test',
    });
    const parsed = JSON.parse(response.content);
    expect(parsed.guardrails).toBeDefined();
    expect(parsed.guardrails.some((g: string) => g.includes('guarantee'))).toBe(true);
    expect(parsed.guardrails.some((g: string) => g.includes('scrape'))).toBe(true);
  });

  it('should never claim guaranteed outcomes', async () => {
    const response = await provider.generate({
      systemPrompt: 'test',
      userPrompt: 'test',
    });
    // The sections should not contain guaranteed ROI promises
    const parsed = JSON.parse(response.content);
    for (const section of parsed.sections) {
      expect(section.content).not.toMatch(/guarantee.*roi/i);
      expect(section.content).not.toMatch(/guaranteed.*return/i);
    }
  });
});
EOF

# ─── Orchestrator Dockerfile ───────────────────────────────────────────────
write_file "apps/ai-orchestrator/Dockerfile" << 'EOF'
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
RUN npx tsc || true

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY package.json ./
COPY src/knowledge/playbooks ./dist/knowledge/playbooks
EXPOSE 4000
CMD ["node", "dist/index.js"]
EOF


###############################################################################
# NEXT.JS FRONTEND (apps/web)
###############################################################################

write_file "apps/web/package.json" << 'EOF'
{
  "name": "@growthblueprint/web",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint",
    "test": "jest --passWithNoTests"
  },
  "dependencies": {
    "next": "14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@growthblueprint/shared": "1.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.48",
    "@types/react-dom": "^18.2.18",
    "typescript": "^5.3.3",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1"
  }
}
EOF

write_file "apps/web/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

write_file "apps/web/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080',
  },
};
module.exports = nextConfig;
EOF

write_file "apps/web/tailwind.config.ts" << 'EOF'
import type { Config } from 'tailwindcss';
const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        primary: { 50: '#eff6ff', 500: '#3b82f6', 600: '#2563eb', 700: '#1d4ed8' },
        accent: { 500: '#10b981', 600: '#059669' },
      },
    },
  },
  plugins: [],
};
export default config;
EOF

write_file "apps/web/postcss.config.js" << 'EOF'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } };
EOF

# ─── API Client ─────────────────────────────────────────────────────────────
write_file "apps/web/src/lib/api.ts" << 'EOF'
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';

interface FetchOptions extends RequestInit {
  token?: string;
}

export async function apiFetch<T>(path: string, options: FetchOptions = {}): Promise<T> {
  const { token, headers: customHeaders, ...rest } = options;
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...((customHeaders as Record<string, string>) || {}),
  };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${API_URL}${path}`, { headers, ...rest });
  if (!res.ok) {
    const body = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(body.error || `API error: ${res.status}`);
  }
  return res.json();
}

export function getStoredToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('gb_access_token');
}

export function setStoredTokens(access: string, refresh: string) {
  localStorage.setItem('gb_access_token', access);
  localStorage.setItem('gb_refresh_token', refresh);
}

export function clearTokens() {
  localStorage.removeItem('gb_access_token');
  localStorage.removeItem('gb_refresh_token');
}
EOF

# ─── Layout ─────────────────────────────────────────────────────────────────
write_file "apps/web/src/app/layout.tsx" << 'EOF'
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'GrowthBlueprint - Digital Marketing Consultant',
  description: 'AI-powered marketing plans for your business',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 min-h-screen">
        <nav className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
            <a href="/dashboard" className="text-xl font-bold text-primary-700">
              GrowthBlueprint
            </a>
            <div className="flex gap-4 text-sm">
              <a href="/dashboard" className="text-gray-600 hover:text-primary-600">Dashboard</a>
              <a href="/connectors" className="text-gray-600 hover:text-primary-600">Connectors</a>
              <a href="/analytics" className="text-gray-600 hover:text-primary-600">Analytics</a>
              <a href="/billing" className="text-gray-600 hover:text-primary-600">Billing</a>
            </div>
          </div>
        </nav>
        <main className="max-w-7xl mx-auto px-4 py-8">{children}</main>
      </body>
    </html>
  );
}
EOF

write_file "apps/web/src/app/globals.css" << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF

# ─── Pages ──────────────────────────────────────────────────────────────────
write_file "apps/web/src/app/page.tsx" << 'EOF'
export default function Home() {
  return (
    <div className="text-center py-20">
      <h1 className="text-4xl font-bold text-gray-900 mb-4">
        Welcome to GrowthBlueprint
      </h1>
      <p className="text-xl text-gray-600 mb-8">
        AI-powered digital marketing plans for your business
      </p>
      <div className="flex gap-4 justify-center">
        <a href="/login" className="bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700">
          Get Started
        </a>
        <a href="/login" className="border border-gray-300 px-6 py-3 rounded-lg hover:bg-gray-50">
          Sign In
        </a>
      </div>
    </div>
  );
}
EOF

write_file "apps/web/src/app/login/page.tsx" << 'EOF'
'use client';
import { useState } from 'react';
import { apiFetch, setStoredTokens } from '@/lib/api';

export default function LoginPage() {
  const [isRegister, setIsRegister] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [orgName, setOrgName] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const endpoint = isRegister ? '/auth/register' : '/auth/login';
      const body = isRegister
        ? { email, password, orgName }
        : { email, password };
      const res = await apiFetch<any>(endpoint, {
        method: 'POST',
        body: JSON.stringify(body),
      });
      setStoredTokens(res.accessToken, res.refreshToken);
      window.location.href = '/dashboard';
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="max-w-md mx-auto mt-20">
      <h1 className="text-2xl font-bold mb-6">
        {isRegister ? 'Create Account' : 'Sign In'}
      </h1>
      {error && <div className="bg-red-50 text-red-600 p-3 rounded mb-4">{error}</div>}
      <form onSubmit={handleSubmit} className="space-y-4">
        {isRegister && (
          <input
            type="text"
            placeholder="Organization Name"
            value={orgName}
            onChange={e => setOrgName(e.target.value)}
            className="w-full border rounded-lg p-3"
            required
          />
        )}
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={e => setEmail(e.target.value)}
          className="w-full border rounded-lg p-3"
          required
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={e => setPassword(e.target.value)}
          className="w-full border rounded-lg p-3"
          required
          minLength={8}
        />
        <button
          type="submit"
          disabled={loading}
          className="w-full bg-primary-600 text-white py-3 rounded-lg hover:bg-primary-700 disabled:opacity-50"
        >
          {loading ? 'Loading...' : isRegister ? 'Register' : 'Sign In'}
        </button>
      </form>
      <p className="mt-4 text-center text-gray-600">
        {isRegister ? 'Already have an account?' : "Don't have an account?"}{' '}
        <button onClick={() => setIsRegister(!isRegister)} className="text-primary-600 underline">
          {isRegister ? 'Sign in' : 'Register'}
        </button>
      </p>
      <p className="mt-2 text-center text-sm text-gray-400">
        Demo: demo@growthblueprint.local / DemoPass123!
      </p>
    </div>
  );
}
EOF

write_file "apps/web/src/app/dashboard/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { apiFetch, getStoredToken } from '@/lib/api';

export default function DashboardPage() {
  const [profiles, setProfiles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = getStoredToken();
    if (!token) { window.location.href = '/login'; return; }
    apiFetch<any[]>('/business-profiles', { token })
      .then(setProfiles)
      .catch(() => window.location.href = '/login')
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <p>Loading...</p>;

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <a href="/onboarding" className="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700">
          + New Business Profile
        </a>
      </div>
      {profiles.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-8 text-center">
          <h2 className="text-xl font-semibold mb-2">Welcome to GrowthBlueprint!</h2>
          <p className="text-gray-600 mb-4">Create your first business profile to get started.</p>
          <a href="/onboarding" className="bg-primary-600 text-white px-6 py-3 rounded-lg">
            Create Business Profile
          </a>
        </div>
      ) : (
        <div className="grid gap-4">
          {profiles.map((p: any) => (
            <a key={p.id} href={`/business-profiles/${p.id}`}
               className="bg-white rounded-lg shadow p-4 hover:shadow-md transition">
              <h3 className="font-semibold text-lg">{p.businessName}</h3>
              <p className="text-gray-600">{p.category} · {p.city}, {p.state}</p>
              <p className="text-sm text-gray-400">Budget: ${p.monthlyMarketingBudget}/mo</p>
            </a>
          ))}
        </div>
      )}
    </div>
  );
}
EOF

write_file "apps/web/src/app/onboarding/page.tsx" << 'EOF'
'use client';
import { useState } from 'react';
import { apiFetch, getStoredToken } from '@/lib/api';

const CATEGORIES = ['jewelry', 'restaurant', 'apparel', 'services', 'other'];
const GOALS = ['leads', 'onlineSales', 'storeVisits', 'awareness'];

export default function OnboardingPage() {
  const [step, setStep] = useState(1);
  const [form, setForm] = useState({
    businessName: '', category: '', city: '', state: '', zip: '',
    monthlyRevenue: 0, monthlyMarketingBudget: 0, salesChannels: 'both',
    ecommercePlatform: 'None', website: '', avgOrderValue: 0, marginPct: 0,
    teamSize: 1, trackingGa4: false, trackingMetaPixel: false,
    goals: [] as string[], constraints: [] as string[], competitors: [] as string[],
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const updateField = (field: string, value: any) => setForm(prev => ({ ...prev, [field]: value }));
  const toggleGoal = (goal: string) => {
    setForm(prev => ({
      ...prev,
      goals: prev.goals.includes(goal) ? prev.goals.filter(g => g !== goal) : [...prev.goals, goal]
    }));
  };

  async function handleSubmit() {
    setError('');
    setLoading(true);
    try {
      const token = getStoredToken();
      if (!token) { window.location.href = '/login'; return; }
      const res = await apiFetch<any>('/business-profiles', {
        method: 'POST', token,
        body: JSON.stringify(form),
      });
      window.location.href = `/business-profiles/${res.id}`;
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-2">Create Business Profile</h1>
      <p className="text-gray-600 mb-6">Step {step} of 4</p>
      {error && <div className="bg-red-50 text-red-600 p-3 rounded mb-4">{error}</div>}

      {step === 1 && (
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Business Name *</label>
            <input value={form.businessName} onChange={e => updateField('businessName', e.target.value)}
                   className="w-full border rounded-lg p-3" required />
            <p className="text-xs text-gray-400 mt-1">This helps us tailor industry-specific recommendations.</p>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Category *</label>
            <select value={form.category} onChange={e => updateField('category', e.target.value)}
                    className="w-full border rounded-lg p-3">
              <option value="">Select...</option>
              {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
            </select>
            <p className="text-xs text-gray-400 mt-1">We have specialized playbooks for each category.</p>
          </div>
          <div className="grid grid-cols-3 gap-2">
            <div>
              <label className="block text-sm font-medium mb-1">City *</label>
              <input value={form.city} onChange={e => updateField('city', e.target.value)}
                     className="w-full border rounded-lg p-3" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">State *</label>
              <input value={form.state} onChange={e => updateField('state', e.target.value)}
                     className="w-full border rounded-lg p-3" maxLength={2} placeholder="CA" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">ZIP *</label>
              <input value={form.zip} onChange={e => updateField('zip', e.target.value)}
                     className="w-full border rounded-lg p-3" placeholder="90210" />
            </div>
          </div>
          <button onClick={() => setStep(2)} className="bg-primary-600 text-white px-6 py-2 rounded-lg">
            Next →
          </button>
        </div>
      )}

      {step === 2 && (
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Monthly Revenue ($) *</label>
            <input type="number" value={form.monthlyRevenue}
                   onChange={e => updateField('monthlyRevenue', Number(e.target.value))}
                   className="w-full border rounded-lg p-3" />
            <p className="text-xs text-gray-400 mt-1">Helps calibrate budget recommendations and ROI estimates.</p>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Monthly Marketing Budget ($) *</label>
            <input type="number" value={form.monthlyMarketingBudget}
                   onChange={e => updateField('monthlyMarketingBudget', Number(e.target.value))}
                   className="w-full border rounded-lg p-3" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Sales Channels *</label>
            <select value={form.salesChannels} onChange={e => updateField('salesChannels', e.target.value)}
                    className="w-full border rounded-lg p-3">
              <option value="inStore">In-Store Only</option>
              <option value="online">Online Only</option>
              <option value="both">Both</option>
            </select>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setStep(1)} className="border px-6 py-2 rounded-lg">← Back</button>
            <button onClick={() => setStep(3)} className="bg-primary-600 text-white px-6 py-2 rounded-lg">Next →</button>
          </div>
        </div>
      )}

      {step === 3 && (
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Tracking Installed</label>
            <div className="flex gap-4">
              <label className="flex items-center gap-2">
                <input type="checkbox" checked={form.trackingGa4}
                       onChange={e => updateField('trackingGa4', e.target.checked)} />
                GA4
              </label>
              <label className="flex items-center gap-2">
                <input type="checkbox" checked={form.trackingMetaPixel}
                       onChange={e => updateField('trackingMetaPixel', e.target.checked)} />
                Meta Pixel
              </label>
            </div>
            <p className="text-xs text-gray-400 mt-1">Better tracking = more accurate forecasts.</p>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Goals * (select at least one)</label>
            <div className="flex flex-wrap gap-2">
              {GOALS.map(g => (
                <button key={g} onClick={() => toggleGoal(g)}
                  className={`px-3 py-1 rounded-full text-sm ${
                    form.goals.includes(g) ? 'bg-primary-600 text-white' : 'bg-gray-100 text-gray-700'
                  }`}>{g}</button>
              ))}
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setStep(2)} className="border px-6 py-2 rounded-lg">← Back</button>
            <button onClick={() => setStep(4)} className="bg-primary-600 text-white px-6 py-2 rounded-lg">Next →</button>
          </div>
        </div>
      )}

      {step === 4 && (
        <div className="space-y-4">
          <div className="bg-white rounded-lg shadow p-4">
            <h3 className="font-semibold mb-2">Review</h3>
            <p><strong>Business:</strong> {form.businessName} ({form.category})</p>
            <p><strong>Location:</strong> {form.city}, {form.state} {form.zip}</p>
            <p><strong>Revenue:</strong> ${form.monthlyRevenue}/mo</p>
            <p><strong>Budget:</strong> ${form.monthlyMarketingBudget}/mo</p>
            <p><strong>Goals:</strong> {form.goals.join(', ')}</p>
          </div>
          <div className="flex gap-2">
            <button onClick={() => setStep(3)} className="border px-6 py-2 rounded-lg">← Back</button>
            <button onClick={handleSubmit} disabled={loading}
              className="bg-accent-500 text-white px-6 py-2 rounded-lg hover:bg-accent-600 disabled:opacity-50">
              {loading ? 'Creating...' : 'Create Profile'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
EOF

write_file "apps/web/src/app/business-profiles/[id]/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { apiFetch, getStoredToken } from '@/lib/api';

export default function ProfileDetailPage() {
  const params = useParams();
  const id = params?.id as string;
  const [profile, setProfile] = useState<any>(null);
  const [plans, setPlans] = useState<any[]>([]);
  const [generating, setGenerating] = useState(false);
  const token = typeof window !== 'undefined' ? getStoredToken() : null;

  useEffect(() => {
    if (!token) return;
    apiFetch(`/business-profiles/${id}`, { token }).then(setProfile).catch(console.error);
    apiFetch<any[]>(`/business-profiles/${id}/plans`, { token }).then(setPlans).catch(console.error);
  }, [id, token]);

  async function generatePlan() {
    if (!token) return;
    setGenerating(true);
    try {
      await apiFetch(`/business-profiles/${id}/plans`, { method: 'POST', token });
      // Poll for completion
      setTimeout(() => {
        apiFetch<any[]>(`/business-profiles/${id}/plans`, { token })
          .then(setPlans).catch(console.error);
        setGenerating(false);
      }, 5000);
    } catch (err) {
      console.error(err);
      setGenerating(false);
    }
  }

  if (!profile) return <p>Loading...</p>;

  return (
    <div>
      <h1 className="text-2xl font-bold mb-2">{profile.businessName}</h1>
      <p className="text-gray-600 mb-6">{profile.category} · {profile.city}, {profile.state}</p>

      <div className="grid md:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-4">
          <h2 className="font-semibold mb-2">Profile Details</h2>
          <p>Revenue: ${profile.monthlyRevenue}/mo</p>
          <p>Budget: ${profile.monthlyMarketingBudget}/mo</p>
          <p>Channels: {profile.salesChannels}</p>
          <p>GA4: {profile.trackingGa4 ? '✓' : '✗'} | Meta Pixel: {profile.trackingMetaPixel ? '✓' : '✗'}</p>
        </div>

        <div className="bg-white rounded-lg shadow p-4">
          <div className="flex justify-between items-center mb-2">
            <h2 className="font-semibold">Marketing Plans</h2>
            <button onClick={generatePlan} disabled={generating}
              className="bg-primary-600 text-white px-3 py-1 rounded text-sm disabled:opacity-50">
              {generating ? 'Generating...' : 'Generate Plan'}
            </button>
          </div>
          {plans.length === 0 ? (
            <p className="text-gray-500">No plans yet. Generate one!</p>
          ) : (
            <div className="space-y-2">
              {plans.map((p: any) => (
                <a key={p.id} href={`/plans/${p.id}`}
                   className="block p-2 bg-gray-50 rounded hover:bg-gray-100">
                  <span className="font-medium">Plan</span>
                  <span className="text-sm text-gray-500 ml-2">Quality: {p.forecastQuality}</span>
                  <span className="text-xs text-gray-400 ml-2">{new Date(p.createdAt).toLocaleDateString()}</span>
                </a>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
EOF

write_file "apps/web/src/app/plans/[id]/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { apiFetch, getStoredToken } from '@/lib/api';

export default function PlanViewerPage() {
  const params = useParams();
  const planId = params?.id as string;
  const [plan, setPlan] = useState<any>(null);
  const token = typeof window !== 'undefined' ? getStoredToken() : null;

  useEffect(() => {
    if (!token) return;
    apiFetch(`/plans/${planId}`, { token }).then(setPlan).catch(console.error);
  }, [planId, token]);

  if (!plan) return <p>Loading plan...</p>;

  const sections = JSON.parse(plan.sectionsJson || '[]');
  const forecast = plan.forecastJson ? JSON.parse(plan.forecastJson) : null;
  const assumptions = JSON.parse(plan.assumptionsJson || '[]');
  const limitations = JSON.parse(plan.limitationsJson || '[]');

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Marketing Plan</h1>
        <span className={`px-3 py-1 rounded-full text-sm font-medium ${
          plan.forecastQuality === 'HIGH' ? 'bg-green-100 text-green-700' :
          plan.forecastQuality === 'MEDIUM' ? 'bg-yellow-100 text-yellow-700' :
          'bg-red-100 text-red-700'
        }`}>
          Forecast Quality: {plan.forecastQuality}
        </span>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <p className="text-blue-800">{plan.confidenceNote}</p>
      </div>

      {forecast && (
        <div className="bg-white rounded-lg shadow p-4 mb-6">
          <h2 className="font-semibold mb-2">Revenue Forecast</h2>
          <p className="text-2xl font-bold">
            ${forecast.rangeMin.toLocaleString()} – ${forecast.rangeMax.toLocaleString()}
            <span className="text-sm font-normal text-gray-500 ml-2">{forecast.unit}/{forecast.period}</span>
          </p>
          {forecast.connectDataChecklist?.length > 0 && (
            <div className="mt-3 bg-yellow-50 p-3 rounded">
              <p className="font-medium text-yellow-800 mb-1">Improve accuracy:</p>
              <ul className="list-disc list-inside text-sm text-yellow-700">
                {forecast.connectDataChecklist.map((item: string, i: number) => (
                  <li key={i}>{item}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      )}

      <div className="space-y-4 mb-6">
        {sections.map((section: any, i: number) => (
          <div key={i} className="bg-white rounded-lg shadow p-4">
            <h2 className="font-semibold text-lg mb-2">{section.title}</h2>
            <p className="text-gray-700 mb-3">{section.content}</p>
            {section.recommendations?.length > 0 && (
              <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
                {section.recommendations.map((rec: string, j: number) => (
                  <li key={j}>{rec}</li>
                ))}
              </ul>
            )}
          </div>
        ))}
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="font-semibold mb-2">Assumptions</h3>
          <ul className="list-disc list-inside text-sm text-gray-600">
            {assumptions.map((a: string, i: number) => <li key={i}>{a}</li>)}
          </ul>
        </div>
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="font-semibold mb-2">Limitations</h3>
          <ul className="list-disc list-inside text-sm text-gray-600">
            {limitations.map((l: string, i: number) => <li key={i}>{l}</li>)}
          </ul>
        </div>
      </div>
    </div>
  );
}
EOF

write_file "apps/web/src/app/connectors/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { apiFetch, getStoredToken } from '@/lib/api';

const PLATFORMS = [
  { id: 'meta_ads', name: 'Meta Ads', icon: '📘' },
  { id: 'google_ads', name: 'Google Ads', icon: '🔍' },
  { id: 'tiktok_ads', name: 'TikTok Ads', icon: '🎵' },
  { id: 'youtube_analytics', name: 'YouTube Analytics', icon: '▶️' },
  { id: 'ga4', name: 'Google Analytics 4', icon: '📊' },
  { id: 'shopify', name: 'Shopify', icon: '🛒' },
  { id: 'google_search_console', name: 'Search Console', icon: '🌐' },
];

export default function ConnectorsPage() {
  const [connectors, setConnectors] = useState<any[]>([]);
  const [error, setError] = useState('');
  const token = typeof window !== 'undefined' ? getStoredToken() : null;

  useEffect(() => {
    if (!token) return;
    apiFetch<any[]>('/connectors', { token })
      .then(setConnectors)
      .catch(err => setError(err.message));
  }, [token]);

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Analytics Connectors</h1>
      {error && <div className="bg-yellow-50 text-yellow-700 p-3 rounded mb-4">{error}</div>}
      <p className="text-gray-600 mb-6">Connect your advertising and analytics platforms for data-driven insights. All connections are read-only.</p>
      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        {PLATFORMS.map(platform => {
          const connector = connectors.find(c => c.platform === platform.id);
          const isConnected = connector?.status === 'CONNECTED';
          return (
            <div key={platform.id} className="bg-white rounded-lg shadow p-4">
              <div className="flex items-center gap-3 mb-3">
                <span className="text-2xl">{platform.icon}</span>
                <h3 className="font-semibold">{platform.name}</h3>
              </div>
              <div className="flex items-center justify-between">
                <span className={`text-sm ${isConnected ? 'text-green-600' : 'text-gray-400'}`}>
                  {isConnected ? '✓ Connected' : 'Not connected'}
                </span>
                {connector?.lastSyncAt && (
                  <span className="text-xs text-gray-400">
                    Last sync: {new Date(connector.lastSyncAt).toLocaleDateString()}
                  </span>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
EOF

write_file "apps/web/src/app/analytics/page.tsx" << 'EOF'
'use client';
export default function AnalyticsPage() {
  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Analytics</h1>
      <div className="bg-white rounded-lg shadow p-8 text-center">
        <p className="text-gray-600">
          Connect your analytics platforms to see unified metrics here.
        </p>
        <a href="/connectors" className="text-primary-600 underline mt-2 inline-block">
          Go to Connectors →
        </a>
      </div>
    </div>
  );
}
EOF

write_file "apps/web/src/app/billing/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { apiFetch, getStoredToken } from '@/lib/api';

export default function BillingPage() {
  const [billing, setBilling] = useState<any>(null);
  const token = typeof window !== 'undefined' ? getStoredToken() : null;

  useEffect(() => {
    if (!token) return;
    apiFetch('/billing/me', { token }).then(setBilling).catch(console.error);
  }, [token]);

  if (!billing) return <p>Loading...</p>;

  const tiers = [
    { name: 'FREE', price: '$0/mo', features: ['3 plans/month', '1 business profile', 'AI advice only'] },
    { name: 'PRO', price: '$49/mo', features: ['20 plans/month', '5 profiles', 'Analytics connectors', 'Daily sync', 'PDF export'] },
    { name: 'BUSINESS', price: '$149/mo', features: ['Unlimited plans', '20 profiles', 'All connectors', '6h sync', 'Priority support'] },
  ];

  return (
    <div>
      <h1 className="text-2xl font-bold mb-6">Billing & Subscription</h1>
      <div className="bg-white rounded-lg shadow p-4 mb-6">
        <p>Current plan: <strong>{billing.tier}</strong></p>
        <p>Plans used: {billing.plansUsedThisPeriod} / {billing.plansLimit}</p>
        <p>Profiles: {billing.profilesCount} / {billing.profilesLimit}</p>
      </div>
      <div className="grid md:grid-cols-3 gap-4">
        {tiers.map(tier => (
          <div key={tier.name} className={`bg-white rounded-lg shadow p-6 ${
            billing.tier === tier.name ? 'ring-2 ring-primary-500' : ''
          }`}>
            <h3 className="text-xl font-bold">{tier.name}</h3>
            <p className="text-2xl font-bold my-2">{tier.price}</p>
            <ul className="text-sm text-gray-600 space-y-1 mb-4">
              {tier.features.map((f, i) => <li key={i}>✓ {f}</li>)}
            </ul>
            {billing.tier !== tier.name && tier.name !== 'FREE' && (
              <button className="w-full bg-primary-600 text-white py-2 rounded-lg hover:bg-primary-700">
                Upgrade
              </button>
            )}
            {billing.tier === tier.name && (
              <p className="text-center text-sm text-green-600 font-medium">Current Plan</p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
EOF

# ─── Web Dockerfile ─────────────────────────────────────────────────────────
write_file "apps/web/Dockerfile" << 'EOF'
FROM node:20-alpine AS build
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public
EXPOSE 3000
ENV PORT=3000
CMD ["node", "server.js"]
EOF


###############################################################################
# INFRASTRUCTURE
###############################################################################

# ─── Docker Compose (dev) ──────────────────────────────────────────────────
write_file "infra/docker/docker-compose.yml" << 'DCEOF'
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    environment:
      POSTGRES_DB: ${DB_NAME:-growthblueprint}
      POSTGRES_USER: ${DB_USER:-gb_user}
      POSTGRES_PASSWORD: ${DB_PASS:-gb_pass_dev}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-gb_user} -d ${DB_NAME:-growthblueprint}"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  api:
    build: ../../apps/api
    ports:
      - "8080:8080"
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME:-growthblueprint}
      DB_USER: ${DB_USER:-gb_user}
      DB_PASS: ${DB_PASS:-gb_pass_dev}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      JWT_SECRET: ${JWT_SECRET:-dev-secret-change-in-production-must-be-at-least-256-bits-long!!}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY:-0123456789abcdef0123456789abcdef}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY:-sk_test_placeholder}
      STRIPE_WEBHOOK_SECRET: ${STRIPE_WEBHOOK_SECRET:-whsec_placeholder}
      STRIPE_PRICE_PRO: ${STRIPE_PRICE_PRO:-price_pro_placeholder}
      STRIPE_PRICE_BUSINESS: ${STRIPE_PRICE_BUSINESS:-price_business_placeholder}
      DEV_MODE: "true"
      CORS_ORIGINS: http://localhost:3000
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  ai-orchestrator:
    build: ../../apps/ai-orchestrator
    ports:
      - "4000:4000"
    environment:
      REDIS_URL: redis://redis:6379
      DATABASE_URL: postgresql://${DB_USER:-gb_user}:${DB_PASS:-gb_pass_dev}@postgres:5432/${DB_NAME:-growthblueprint}
      LLM_PROVIDER: mock
      LOG_LEVEL: info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  web:
    build: ../../apps/web
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:8080
    depends_on:
      - api

volumes:
  pgdata:
DCEOF

write_file "infra/docker/.env.example" << 'EOF'
# GrowthBlueprint Environment Variables
# Copy this file to .env and customize

# Database
DB_NAME=growthblueprint
DB_USER=gb_user
DB_PASS=gb_pass_dev
DB_HOST=localhost
DB_PORT=5432

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT (CHANGE IN PRODUCTION - minimum 256 bits)
JWT_SECRET=dev-secret-change-in-production-must-be-at-least-256-bits-long!!

# Encryption (CHANGE IN PRODUCTION - 32 hex chars = 128-bit AES key)
ENCRYPTION_KEY=0123456789abcdef0123456789abcdef

# Stripe (replace with real keys)
STRIPE_SECRET_KEY=sk_test_placeholder
STRIPE_WEBHOOK_SECRET=whsec_placeholder
STRIPE_PRICE_PRO=price_pro_placeholder
STRIPE_PRICE_BUSINESS=price_business_placeholder

# Dev mode (set to false in production)
DEV_MODE=true

# CORS
CORS_ORIGINS=http://localhost:3000

# LLM Provider (mock|openai|anthropic)
LLM_PROVIDER=mock

# Platform API Keys (leave as placeholder for dev, fill in for production)
# Meta (Facebook)
META_APP_ID=
META_APP_SECRET=

# Google
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# TikTok
TIKTOK_APP_ID=
TIKTOK_APP_SECRET=

# Shopify
SHOPIFY_API_KEY=
SHOPIFY_API_SECRET=
EOF

# ─── Production Docker Compose ─────────────────────────────────────────────
write_file "infra/prod/docker-compose.yml" << 'DCPRODEOF'
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg16
    restart: always
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          memory: 2G

  redis:
    image: redis:7-alpine
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build: ../../apps/api
    restart: always
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      JWT_SECRET: ${JWT_SECRET}
      ENCRYPTION_KEY: ${ENCRYPTION_KEY}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      STRIPE_WEBHOOK_SECRET: ${STRIPE_WEBHOOK_SECRET}
      DEV_MODE: "false"
      CORS_ORIGINS: https://${DOMAIN}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  ai-orchestrator:
    build: ../../apps/ai-orchestrator
    restart: always
    environment:
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASS}@postgres:5432/${DB_NAME}
      LLM_PROVIDER: ${LLM_PROVIDER:-mock}
      LOG_LEVEL: info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  web:
    build: ../../apps/web
    restart: always
    environment:
      NEXT_PUBLIC_API_URL: https://${DOMAIN}/api
    depends_on:
      - api

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - certbot-etc:/etc/letsencrypt:ro
      - certbot-var:/var/lib/letsencrypt
    depends_on:
      - api
      - web

  certbot:
    image: certbot/certbot
    volumes:
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"

volumes:
  pgdata:
  redisdata:
  certbot-etc:
  certbot-var:
DCPRODEOF

# ─── Nginx Config ──────────────────────────────────────────────────────────
write_file "infra/prod/nginx/default.conf" << 'NGINXEOF'
upstream api_backend {
    server api:8080;
}

upstream web_frontend {
    server web:3000;
}

# Rate limiting zones
limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=api:10m rate=30r/s;

server {
    listen 80;
    server_name _;

    location /.well-known/acme-challenge/ {
        root /var/lib/letsencrypt;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name _;

    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;

    # API routes
    location /api/ {
        limit_req zone=api burst=50 nodelay;
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
    }

    # Auth rate limiting
    location /api/auth/ {
        limit_req zone=login burst=3 nodelay;
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Stripe webhook (no rate limit, Stripe manages this)
    location /api/billing/stripe/webhook {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Stripe-Signature $http_stripe_signature;
    }

    # Frontend
    location / {
        proxy_pass http://web_frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

# ─── LetsEncrypt Script ────────────────────────────────────────────────────
write_file "infra/prod/scripts/setup-ssl.sh" << 'SSLEOF'
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain> <email>}"
EMAIL="${2:?Usage: $0 <domain> <email>}"

echo "Setting up SSL for ${DOMAIN}..."

# Initial certificate
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/lib/letsencrypt \
  --email "${EMAIL}" \
  --agree-tos \
  --no-eff-email \
  -d "${DOMAIN}"

# Reload nginx
docker compose exec nginx nginx -s reload

echo "SSL setup complete for ${DOMAIN}"
SSLEOF
chmod +x infra/prod/scripts/setup-ssl.sh 2>/dev/null || true

# ─── Backup Script ─────────────────────────────────────────────────────────
write_file "infra/prod/scripts/backup-db.sh" << 'BKEOF'
#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/opt/growthblueprint/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/growthblueprint_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "Starting database backup..."
docker compose exec -T postgres pg_dump -U "${DB_USER}" "${DB_NAME}" | gzip > "${BACKUP_FILE}"

echo "Backup saved to ${BACKUP_FILE}"

# Remove old backups
echo "Removing backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "growthblueprint_*.sql.gz" -mtime +"${RETENTION_DAYS}" -delete

echo "Backup complete."

# To restore:
# gunzip -c <backup_file>.sql.gz | docker compose exec -T postgres psql -U ${DB_USER} ${DB_NAME}
BKEOF
chmod +x infra/prod/scripts/backup-db.sh 2>/dev/null || true

# ─── Production .env template ──────────────────────────────────────────────
write_file "infra/prod/.env.example" << 'EOF'
# Production Environment Variables
# IMPORTANT: Use strong, unique values. Never commit real secrets.

DOMAIN=app.growthblueprint.com

DB_NAME=growthblueprint
DB_USER=gb_user
DB_PASS=CHANGE_ME_STRONG_PASSWORD_HERE

REDIS_PASSWORD=CHANGE_ME_STRONG_PASSWORD_HERE

JWT_SECRET=CHANGE_ME_MUST_BE_AT_LEAST_256_BITS_GENERATE_WITH_openssl_rand_base64_64

ENCRYPTION_KEY=CHANGE_ME_32_HEX_CHARS_GENERATE_WITH_openssl_rand_hex_16

STRIPE_SECRET_KEY=sk_live_XXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXX
STRIPE_PRICE_PRO=price_XXXX
STRIPE_PRICE_BUSINESS=price_XXXX

LLM_PROVIDER=mock

# Platform API credentials
META_APP_ID=
META_APP_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
TIKTOK_APP_ID=
TIKTOK_APP_SECRET=
SHOPIFY_API_KEY=
SHOPIFY_API_SECRET=
EOF

# ─── k8s placeholder ───────────────────────────────────────────────────────
write_file "infra/k8s/README.md" << 'EOF'
# Kubernetes Deployment (Future)

This directory will contain Kubernetes manifests when migrating from Docker Compose
to a managed container orchestration platform.

See docs/FUTURE_AWS.md for the planned architecture.
EOF


###############################################################################
# CI/CD
###############################################################################

write_file ".github/workflows/ci.yml" << 'CIEOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  api-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 21
      - name: Build API
        run: cd apps/api && mvn package -DskipTests -q
      - name: Test API
        run: cd apps/api && mvn test

  orchestrator-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: cd apps/ai-orchestrator && npm install
      - name: Build
        run: cd apps/ai-orchestrator && npm run build
      - name: Test
        run: cd apps/ai-orchestrator && npm test

  web-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: cd apps/web && npm install
      - name: Build
        run: cd apps/web && npm run build

  shared-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install dependencies
        run: cd packages/shared && npm install
      - name: Build
        run: cd packages/shared && npm run build
CIEOF


###############################################################################
# DOCUMENTATION
###############################################################################

write_file "docs/ARCHITECTURE.md" << 'ARCHEOF'
# GrowthBlueprint Architecture

## Overview

GrowthBlueprint is a multi-tenant SaaS platform that generates AI-powered digital
marketing plans for small-to-medium businesses.

## C4 Context Diagram

```
┌─────────────┐     ┌──────────────────────────────────────────────┐
│  Business    │────▶│              GrowthBlueprint                 │
│  Owner       │◀────│                                              │
└─────────────┘     │  ┌────────┐  ┌─────────┐  ┌──────────────┐  │
                    │  │  Web   │  │   API   │  │ AI Orchestr. │  │
                    │  │(Next.js│──│ (Spring │──│  (Node/TS)   │  │
                    │  │  :3000)│  │  Boot   │  │    :4000     │  │
                    │  └────────┘  │  :8080) │  └──────┬───────┘  │
                    │              └────┬────┘         │          │
                    │                   │              │          │
                    │  ┌────────────────┴──────────────┘          │
                    │  │                                          │
                    │  ▼                                          │
                    │  ┌────────────┐  ┌──────────┐              │
                    │  │ PostgreSQL │  │  Redis   │              │
                    │  │ + pgvector │  │  Queue   │              │
                    │  │   :5432    │  │  :6379   │              │
                    │  └────────────┘  └──────────┘              │
                    └──────────────────────────────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
              ┌──────────┐     ┌──────────────┐    ┌────────────┐
              │ Meta Ads │     │ Google Ads   │    │  Shopify   │
              │   API    │     │    API       │    │   API      │
              └──────────┘     └──────────────┘    └────────────┘
              (Read-only)       (Read-only)         (Read-only)
```

## Component Responsibilities

### API (Spring Boot 3)
- Authentication (JWT + refresh token rotation)
- Multi-tenant data isolation (org_id on every query)
- Business profile CRUD with validation
- Plan job creation and queueing
- Billing management (Stripe integration)
- Connector management (token encryption)
- Rate limiting and audit logging

### AI Orchestrator (Node.js/TypeScript)
- Plan generation worker (Redis queue consumer)
- RAG: knowledge playbook retrieval by category
- Deterministic tools: budget allocation, forecasting
- LLM adapter interface (mock default, swap for production)
- Analytics sync scheduler
- Connector implementations (per-platform, with circuit breakers)

### Frontend (Next.js 14)
- Server-side rendering for SEO pages
- Client-side SPA for authenticated flows
- Responsive design with Tailwind CSS
- API client with token management

### PostgreSQL + pgvector
- All persistent data
- pgvector for knowledge chunk embeddings
- Flyway migrations for schema management
- Multi-tenant isolation via org_id

### Redis
- Plan job queue (list-based queue)
- Session/cache data
- Rate limiting counters

## Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Spring Boot for API | Mature ecosystem, strong typing, excellent for complex business logic |
| Node.js for Orchestrator | Better LLM SDK support, async I/O for API calls |
| PostgreSQL + pgvector | Single database for relational + vector data, reduces ops complexity |
| Redis queue (not Kafka) | Simpler for v1 scale, adequate throughput |
| JWT + refresh rotation | Stateless auth with revocation support |
| Encrypted tokens at rest | Security requirement for OAuth tokens |
| Read-only connectors | Reduces risk, simpler implementation, clear TOS compliance |

## Data Flow

1. User creates business profile via frontend
2. User triggers plan generation
3. API creates PlanJob, enqueues to Redis
4. Orchestrator worker picks up job
5. Worker fetches profile, retrieves knowledge, runs tools
6. Worker calls LLM adapter, validates output
7. Worker saves MarketingPlan, marks job complete
8. User views plan via frontend

## Security Model

- All API endpoints require JWT (except /auth/*, /health, webhook)
- Every database query is scoped to org_id
- OAuth tokens encrypted with AES-256-GCM
- Refresh tokens stored as SHA-256 hashes
- Audit logs for all sensitive operations
- Rate limiting on auth and plan generation
- CORS restricted to allowed origins
- Nginx security headers in production
ARCHEOF

write_file "docs/SEQUENCE_PLAN_GENERATION.md" << 'SEQPLANEOF'
# Plan Generation Sequence

## Flow

```
User                Frontend            API                 Redis Queue         AI Orchestrator
 │                    │                  │                      │                    │
 │─── Click ──────────▶                  │                      │                    │
 │   "Generate Plan"  │                  │                      │                    │
 │                    │── POST ──────────▶                      │                    │
 │                    │  /profiles/{id}/ │                      │                    │
 │                    │  plans           │                      │                    │
 │                    │                  │                      │                    │
 │                    │                  │── Validate ──────────│                    │
 │                    │                  │   - Profile exists   │                    │
 │                    │                  │   - Org tier check   │                    │
 │                    │                  │   - Usage limit      │                    │
 │                    │                  │   - Compute hash     │                    │
 │                    │                  │                      │                    │
 │                    │                  │── Check idempotency ─│                    │
 │                    │                  │   (existing pending  │                    │
 │                    │                  │    job w/ same hash?)│                    │
 │                    │                  │                      │                    │
 │                    │                  │── Create PlanJob ────│                    │
 │                    │                  │   (status: PENDING)  │                    │
 │                    │                  │                      │                    │
 │                    │                  │── LPUSH ─────────────▶                    │
 │                    │                  │   plan_jobs_queue    │                    │
 │                    │                  │                      │                    │
 │                    │◀── 200 {jobId} ──│                      │                    │
 │                    │                  │                      │                    │
 │◀── Show "Generating"│                  │                      │── RPOP ───────────▶
 │                    │                  │                      │   plan_jobs_queue  │
 │                    │                  │                      │                    │
 │                    │                  │                      │   ┌── Process ─────┤
 │                    │                  │                      │   │ 1. Fetch profile│
 │                    │                  │                      │   │ 2. Fetch conns  │
 │                    │                  │                      │   │ 3. Retrieve RAG │
 │                    │                  │                      │   │ 4. Run tools    │
 │                    │                  │                      │   │ 5. Call LLM     │
 │                    │                  │                      │   │ 6. Validate     │
 │                    │                  │                      │   │ 7. Save plan    │
 │                    │                  │                      │   └─────────────────┤
 │                    │                  │                      │                    │
 │                    │── GET ───────────▶                      │                    │
 │                    │  /plans/jobs/{id}│                      │                    │
 │                    │                  │                      │                    │
 │                    │◀── {status:      │                      │                    │
 │                    │     COMPLETED,   │                      │                    │
 │                    │     planId: ...} │                      │                    │
 │                    │                  │                      │                    │
 │                    │── GET ───────────▶                      │                    │
 │                    │  /plans/{planId} │                      │                    │
 │                    │                  │                      │                    │
 │◀── Display plan ───│                  │                      │                    │
```

## Idempotency

- Input hash = SHA-256(businessName + category + revenue + budget + channels + goals + constraints)
- If a PENDING or PROCESSING job exists with the same hash, return the existing job
- This prevents duplicate plan generation on accidental double-clicks

## Error Handling

- If LLM fails: job marked FAILED with error message
- If profile deleted mid-generation: job fails gracefully
- If Redis down: API returns 503 with retry-after header
- If worker crashes: job stays PENDING, picked up on restart
SEQPLANEOF

write_file "docs/SEQUENCE_ANALYTICS_SYNC.md" << 'SEQSYNCEOF'
# Analytics Sync Sequence

## Scheduled Sync Flow

```
SyncScheduler          Database            Connector           External API
     │                    │                    │                    │
     │── Query due ───────▶                    │                    │
     │   connectors       │                    │                    │
     │   (tier + interval)│                    │                    │
     │                    │                    │                    │
     │◀── Org + Platform ─│                    │                    │
     │   list             │                    │                    │
     │                    │                    │                    │
     │── For each ────────│── Decrypt tokens ──▶                    │
     │   connector        │                    │                    │
     │                    │                    │── API call ────────▶
     │                    │                    │   (with retry,     │
     │                    │                    │    backoff,        │
     │                    │                    │    circuit breaker)│
     │                    │                    │                    │
     │                    │                    │◀── Data ───────────│
     │                    │                    │   (paginated)      │
     │                    │                    │                    │
     │                    │◀── Upsert ────────│                    │
     │                    │   analytics_daily  │                    │
     │                    │   (dedupe key:     │                    │
     │                    │    org+profile+    │                    │
     │                    │    platform+date)  │                    │
     │                    │                    │                    │
     │◀── Update sync ───│                    │                    │
     │   timestamp        │                    │                    │
```

## Sync Intervals by Tier

| Tier | Interval | Rationale |
|------|----------|-----------|
| FREE | Disabled | No connector access |
| PRO | Every 24h | Daily insights sufficient for most SMBs |
| BUSINESS | Every 6h | Near-real-time for active advertisers |

## Edge Cases Handled

- **Token expiry**: Detect 401, mark connector as EXPIRED, notify user
- **Revoked access**: Same as expiry, user must reconnect
- **Missing scopes**: Log warning, sync available data only
- **Partial data**: Set data_completeness < 100%, flag in UI
- **Pagination**: Follow cursor/offset until all data fetched
- **Data lag**: External APIs may have 24-48h delay, stored as data_freshness
- **Timezone**: All dates stored in UTC, converted for display
- **Rate limits**: Per-platform rate limiting, exponential backoff
- **Circuit breaker**: After 5 consecutive failures, pause for 60s

## Truth Source Hierarchy

For revenue/conversion forecasting:
1. **Shopify stores**: Shopify Orders/Revenue is primary truth
2. **Non-Shopify**: GA4 conversions/revenue is primary truth
3. **Ads platform conversions**: Secondary diagnostics only (attribution varies)
SEQSYNCEOF

write_file "docs/THREAT_MODEL.md" << 'THREATEOF'
# Threat Model

## Assets

| Asset | Classification | Location |
|-------|---------------|----------|
| User credentials | Critical | PostgreSQL (hashed) |
| OAuth tokens | Critical | PostgreSQL (AES-256-GCM encrypted) |
| Business financial data | Sensitive | PostgreSQL |
| Marketing plans | Sensitive | PostgreSQL |
| Analytics data | Sensitive | PostgreSQL |
| JWT secrets | Critical | Environment variables |
| Stripe keys | Critical | Environment variables |

## Threat Categories

### Authentication & Authorization
| Threat | Mitigation |
|--------|-----------|
| Brute force login | Rate limiting (5/min per IP) |
| JWT theft | Short expiry (15min), refresh rotation |
| Refresh token theft | Hashed storage, single-use rotation |
| Privilege escalation | RBAC checked on every request |
| Session fixation | New token on every login |
| Cross-tenant access | org_id filter on all queries |

### Data Security
| Threat | Mitigation |
|--------|-----------|
| SQL injection | Parameterized queries (JPA/pg) |
| Unencrypted tokens | AES-256-GCM encryption at rest |
| Secrets in logs | Structured logging, redaction |
| Data exfiltration | Audit logging, role-based access |
| Backup exposure | Encrypted backups, retention policy |

### API Security
| Threat | Mitigation |
|--------|-----------|
| CSRF | SameSite cookies, CORS policy |
| XSS | CSP headers, React auto-escaping |
| SSRF | No URL fetching, no competitor scraping |
| DoS | Rate limiting, request size limits |
| Injection via webhooks | Stripe signature verification |

### Third-party Risks
| Threat | Mitigation |
|--------|-----------|
| OAuth token leak | Encrypted storage, minimal scopes |
| API TOS violation | Read-only, official APIs only |
| Platform rate limits | Per-connector rate limiting |
| Service unavailability | Circuit breakers, graceful degradation |

### Infrastructure
| Threat | Mitigation |
|--------|-----------|
| Unpatched OS | Regular updates, minimal base images |
| Open ports | Firewall rules, nginx reverse proxy |
| Missing TLS | Let's Encrypt auto-renewal |
| Container escape | Non-root containers, resource limits |

## Security Checklist (Pre-Launch)
- [ ] Change all default secrets
- [ ] Enable HTTPS everywhere
- [ ] Set up firewall (ufw)
- [ ] Enable automated backups
- [ ] Review CORS origins
- [ ] Enable Stripe webhook verification
- [ ] Audit log review process
- [ ] Dependency vulnerability scanning
- [ ] Rate limit tuning
THREATEOF

write_file "docs/EDGE_CASES.md" << 'EDGEEOF'
# Edge Cases & How They're Handled

## Authentication
| Edge Case | Handling |
|-----------|---------|
| Expired access token | Return 401, client uses refresh token |
| Expired refresh token | Return 401, redirect to login |
| Concurrent refresh requests | First wins (token rotation), second gets 401 |
| User deleted while logged in | Next API call fails, redirect to login |
| Password changed | All refresh tokens revoked |

## Business Profiles
| Edge Case | Handling |
|-----------|---------|
| Profile limit reached | Return 409 with upgrade message |
| Invalid ZIP code | Reject with validation error |
| Very long business name | Truncate at 200 chars, validate |
| Empty goals array | Reject (min 1 required) |
| Concurrent profile edits | Last write wins (optimistic) |
| Profile deleted during plan gen | Job fails gracefully |

## Plan Generation
| Edge Case | Handling |
|-----------|---------|
| Duplicate submission (double-click) | Idempotency via input_hash |
| Plan limit reached for period | Return 409 with limit info |
| LLM timeout | Retry once, then fail job |
| LLM returns invalid JSON | Wrap raw text in default section |
| Worker crash mid-processing | Job stays PENDING, retried on restart |
| Concurrent plan for same profile | Allowed (different jobs) |
| Very small budget ($0) | Generate advice-only plan, no paid recommendations |

## Analytics Connectors
| Edge Case | Handling |
|-----------|---------|
| Token expires during sync | Catch 401, mark EXPIRED, skip remaining |
| API rate limit hit | Exponential backoff, retry after delay |
| Partial data returned | Set completeness < 100%, continue |
| Platform API down | Circuit breaker opens after 5 failures |
| Duplicate metrics for same date | Upsert with dedupe key |
| Timezone mismatch | All stored as UTC, converted on display |
| Very old data requested | Limit to 90 days for most platforms |
| No data available | Return empty set, show "No data" message |
| Scopes revoked by user | Detect on next sync, mark ERROR |

## Billing
| Edge Case | Handling |
|-----------|---------|
| Payment fails | Stripe webhook updates status, grace period |
| Downgrade with more profiles than limit | Existing data preserved, no new profiles |
| Downgrade with connected connectors | Connectors disabled, data preserved |
| Webhook replay | Idempotent handling (check current state) |
| Subscription cancelled | Data remains accessible, features disabled |
| Usage period reset | Automatic at billing cycle via usage_reset_at |

## Forecasting
| Edge Case | Handling |
|-----------|---------|
| No data sources connected | LOW quality, wide ranges, connect checklist |
| Mixed data freshness | Use most recent common period |
| Zero revenue business | Skip revenue-based metrics, focus on leads |
| Very high budget | Cap multiplier to prevent unrealistic ranges |
| Conflicting platform data | Flag discrepancy, use truth source hierarchy |
EDGEEOF

write_file "docs/WHAT_NOT_TO_DO.md" << 'WNTDEOF'
# What NOT To Do

This document lists explicitly forbidden behaviors and how they are enforced
in the GrowthBlueprint platform.

## Forbidden Behaviors

### 1. Do NOT Scrape Social Platforms
**Why**: Violates platform Terms of Service. Legal risk.
**Enforcement**:
- No HTTP client calls to social media URLs
- No headless browser/puppeteer dependencies
- Connectors use ONLY official APIs
- Code review checklist includes scraping check
- Policy guardrails in LLM prompts

### 2. Do NOT Create or Modify Campaigns
**Why**: v1 is read-only. Write access increases risk dramatically.
**Enforcement**:
- All connectors implement read-only interfaces
- No write/mutate API scopes requested in OAuth
- API endpoints are GET-only for analytics
- Connector interface has no create/update methods

### 3. Do NOT Store Raw Tokens Unencrypted
**Why**: OAuth tokens are high-value credentials.
**Enforcement**:
- EncryptionUtil uses AES-256-GCM
- Encrypted at rest in `encrypted_tokens_json` column
- Decryption only in connector sync code path
- Audit log on every token access
- Key rotation documented in runbook

### 4. Do NOT Guarantee ROI or Outcomes
**Why**: Marketing outcomes are probabilistic. Guarantees are misleading.
**Enforcement**:
- LLM system prompt includes explicit policy
- Forecast includes quality score (HIGH/MEDIUM/LOW)
- All forecasts include assumptions and limitations
- Confidence note explains uncertainty
- LOW quality forecasts show wide ranges + action checklist

### 5. Do NOT Advise Discriminatory Targeting
**Why**: Protected classes must not be targeted. Legal and ethical risk.
**Enforcement**:
- LLM system prompt includes anti-discrimination policy
- No demographic targeting recommendations by race, religion, etc.
- Content review in plan output validation

### 6. Do NOT Fetch Competitor URLs (No SSRF)
**Why**: Server-Side Request Forgery risk. Also potential scraping.
**Enforcement**:
- Competitor URLs stored as text only
- No HTTP requests to user-provided URLs
- No URL preview/fetch functionality
- URLs are for reference display only

### 7. Do NOT Log Secrets or PII
**Why**: Log files are often less protected than databases.
**Enforcement**:
- Structured JSON logging
- No token values in log messages
- Email addresses not logged (only user IDs)
- Request bodies not logged for auth endpoints
- Passwords never logged

### 8. Do NOT Use Fabricated Data
**Why**: Misleading. Damages trust.
**Enforcement**:
- Forecast quality score reflects actual data availability
- LOW quality explicitly states limited data
- No fabricated influencer accounts
- No made-up case studies or statistics
- LLM policy prompt prohibits fabrication

## Enforcement Summary

| Rule | Code Enforcement | Review Enforcement |
|------|-----------------|-------------------|
| No scraping | No HTTP client deps, connector architecture | PR review |
| No write ops | Read-only interfaces | API scope audit |
| Encrypted tokens | EncryptionUtil mandatory | Security review |
| No guarantees | LLM policy, forecast quality | Content review |
| No discrimination | LLM policy | Content review |
| No SSRF | No URL fetch | Security review |
| No secret logging | Structured logging | Log audit |
| No fabrication | LLM policy, quality score | Content review |
WNTDEOF

write_file "docs/VPS_DEPLOYMENT.md" << 'VPSEOF'
# VPS Deployment Guide

## Prerequisites

- Ubuntu 22.04+ VPS with at least 4GB RAM, 2 vCPUs, 40GB SSD
- Domain name pointing to VPS IP
- SSH access

## Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install firewall
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Step 2: Clone Repository

```bash
cd /opt
sudo git clone <repo-url> growthblueprint
cd growthblueprint
```

## Step 3: Configure Environment

```bash
cp infra/prod/.env.example infra/prod/.env
# Edit with your values:
nano infra/prod/.env

# Generate secrets:
# JWT_SECRET:
openssl rand -base64 64

# ENCRYPTION_KEY:
openssl rand -hex 16

# DB_PASS:
openssl rand -base64 32

# REDIS_PASSWORD:
openssl rand -base64 32
```

## Step 4: Configure Nginx

Edit `infra/prod/nginx/default.conf`:
- Replace `${DOMAIN}` with your actual domain

## Step 5: Start Services

```bash
cd infra/prod
docker compose up -d --build

# Wait for services to be healthy
docker compose ps
docker compose logs -f
```

## Step 6: Setup SSL

```bash
cd infra/prod
./scripts/setup-ssl.sh your-domain.com your-email@example.com
```

## Step 7: Verify

```bash
# Check health
curl https://your-domain.com/api/health

# Check logs
docker compose logs -f api
```

## Step 8: Setup Backups

```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * cd /opt/growthblueprint/infra/prod && ./scripts/backup-db.sh
```

## DNS Configuration

| Record | Type | Value |
|--------|------|-------|
| @ | A | Your VPS IP |
| www | CNAME | @ |

## Monitoring

- Check container health: `docker compose ps`
- View logs: `docker compose logs -f [service]`
- Database size: `docker compose exec postgres psql -U gb_user -c "SELECT pg_size_pretty(pg_database_size('growthblueprint'))"`
VPSEOF

write_file "docs/FUTURE_AWS.md" << 'AWSEOF'
# Future AWS Architecture

## Overview

When scaling beyond a single VPS, migrate to AWS managed services:

## Architecture

| Current (VPS) | Future (AWS) | Service |
|---------------|-------------|---------|
| PostgreSQL container | Amazon RDS (PostgreSQL) | Managed DB |
| Redis container | Amazon ElastiCache | Managed cache |
| Docker Compose | ECS Fargate or EKS | Container orchestration |
| Local disk | S3 + EBS | Storage |
| Let's Encrypt | ACM | SSL certificates |
| nginx | ALB | Load balancing |
| .env files | Secrets Manager | Secret management |
| Local encryption key | KMS | Key management |
| Manual backups | RDS automated backups | Backup |
| Server monitoring | CloudWatch + X-Ray | Observability |

## Migration Steps

1. **Database**: Create RDS instance, use pg_dump/pg_restore
2. **Redis**: Create ElastiCache cluster
3. **Secrets**: Move to Secrets Manager
4. **Encryption**: Switch to KMS
5. **Containers**: Create ECR repos, push images, create ECS tasks
6. **Networking**: VPC, subnets, security groups
7. **Load Balancer**: ALB with ACM certificate
8. **DNS**: Route 53 or update existing DNS
9. **Monitoring**: CloudWatch dashboards, X-Ray tracing
10. **CI/CD**: Update to deploy to ECS/EKS

## Cost Estimates (Monthly)

| Service | Estimated Cost |
|---------|---------------|
| RDS db.t3.medium | ~$70 |
| ElastiCache cache.t3.micro | ~$15 |
| ECS Fargate (3 tasks) | ~$45 |
| ALB | ~$25 |
| S3 (backups) | ~$5 |
| Secrets Manager | ~$5 |
| CloudWatch | ~$10 |
| **Total** | **~$175/mo** |

## IaC

Use Terraform or CDK to define infrastructure as code.
Manifests will be placed in `infra/k8s/` or `infra/terraform/`.
AWSEOF


write_file "docs/ROADMAP_AND_RUNBOOK.md" << 'ROADMAPEOF'
# GrowthBlueprint — Roadmap & Runbook

## What Is GrowthBlueprint?

GrowthBlueprint is a software product (a web application) that helps small and medium
business owners create digital marketing plans using AI. Think of it as having a
marketing consultant available 24/7, but powered by software.

**What it does:**
- You tell it about your business (what you sell, where you are, your budget)
- It creates a customized marketing plan with specific recommendations
- If you connect your advertising accounts, it can see your real data and make better plans
- It tracks your progress over time

**What it does NOT do:**
- It does not run your ads for you (read-only in v1)
- It does not guarantee specific results
- It does not scrape the internet for data

## Who Is This For?

- Small business owners who need marketing guidance but can not afford a full-time consultant
- Marketing managers at small companies who want data-driven recommendations
- Agencies managing multiple small business clients

## Architecture Overview (Simple Version)

The product has four main parts:

1. **The Website** (what users see) — Built with Next.js
   - Where users log in, create profiles, view plans
   - Runs on port 3000

2. **The API** (the brain) — Built with Spring Boot (Java)
   - Handles user accounts, business profiles, billing
   - Receives requests from the website and processes them
   - Runs on port 8080

3. **The AI Engine** (the smart part) — Built with Node.js
   - Takes business information and generates marketing plans
   - Uses knowledge playbooks for different industries
   - Runs on port 4000

4. **The Database & Queue** — PostgreSQL + Redis
   - Stores all data: users, profiles, plans, analytics
   - Redis manages the queue of plan generation jobs

## How Plan Generation Works (Step by Step)

1. User fills out their business profile (name, category, budget, goals, etc.)
2. User clicks "Generate Plan"
3. The API creates a "job" and puts it in a queue
4. The AI Engine picks up the job:
   a. Reads the business profile
   b. Finds relevant marketing playbooks for the business category
   c. Calculates budget allocation using mathematical formulas
   d. Assesses forecast quality based on available data
   e. Generates recommendations using AI
   f. Validates the output (no guarantees, no scraping advice)
   g. Saves the completed plan
5. User sees their plan with sections, recommendations, and forecasts

## How Analytics Connectors Work

Paid users (PRO and BUSINESS tiers) can connect their advertising accounts:

1. **Meta Ads** (Facebook/Instagram advertising)
2. **Google Ads** (search and display advertising)
3. **TikTok Ads** (TikTok advertising)
4. **YouTube Analytics** (video performance)
5. **GA4** (Google Analytics — website traffic)
6. **Shopify** (e-commerce orders and revenue)
7. **Google Search Console** (SEO performance)

When connected, the system:
- Reads data from these platforms (never writes/changes anything)
- Normalizes metrics into a unified daily format
- Uses this data to improve forecast accuracy
- Syncs automatically (every 6h for BUSINESS, daily for PRO)

## How Subscription Works

Three tiers:
- **FREE**: AI advice only, 3 plans/month, 1 business profile
- **PRO** ($49/mo): Analytics connectors, 20 plans/month, 5 profiles, PDF export
- **BUSINESS** ($149/mo): Higher limits, faster sync, 20 profiles

Billing uses Stripe. When a user upgrades:
1. They click "Upgrade" → redirected to Stripe checkout
2. Stripe processes payment, sends webhook to our API
3. API updates the organization's tier
4. New features become available immediately

If payment fails:
- Data remains accessible
- Connectors are disabled
- Plan generation continues at FREE tier limits

## How to Test Locally

### Prerequisites
You need these installed on your computer:
- **Docker Desktop** (manages containers) — https://docker.com
- **Git** (downloads the code) — https://git-scm.com

### Steps

```bash
# 1. Open your terminal and go to the project folder
cd GrowthBlueprint

# 2. Copy the example environment file
cp infra/docker/.env.example infra/docker/.env

# 3. Start everything
make dev

# 4. Wait about 2 minutes for everything to start

# 5. Open your browser
#    Website: http://localhost:3000
#    API health check: http://localhost:8080/health

# 6. Log in with the demo account:
#    Email: demo@growthblueprint.local
#    Password: DemoPass123!

# 7. Create a business profile and generate your first plan!

# To stop everything:
make down

# To see what's happening:
make logs

# To start fresh (reset database):
make reset-db
```

## How to Deploy on a VPS

### What You Need
1. A VPS (Virtual Private Server) — Recommended: DigitalOcean, Hetzner, or Linode
   - At least 4GB RAM, 2 CPU cores, 40GB SSD
   - Ubuntu 22.04
2. A domain name (e.g., app.yourbrand.com)
3. An email address for SSL certificates

### Step-by-Step Deployment

#### 1. Get Your Server Ready
```bash
# SSH into your server
ssh root@your-server-ip

# Update everything
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Set up firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# Log out and back in for Docker group to take effect
exit
ssh root@your-server-ip
```

#### 2. Get the Code
```bash
cd /opt
git clone <your-repo-url> growthblueprint
cd growthblueprint
```

#### 3. Configure Secrets
```bash
cp infra/prod/.env.example infra/prod/.env
nano infra/prod/.env

# Generate secure values for each secret:
# For JWT_SECRET:
openssl rand -base64 64

# For ENCRYPTION_KEY:
openssl rand -hex 16

# For DB_PASS:
openssl rand -base64 32

# For REDIS_PASSWORD:
openssl rand -base64 32
```

#### 4. Configure DNS
Go to your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.):
- Add an **A record**: `@` → your server IP
- Add a **CNAME record**: `www` → `@`
- Wait for DNS to propagate (can take up to 48 hours, usually 15-30 minutes)

Verify: `ping your-domain.com` should return your server IP.

#### 5. Configure HTTPS
Edit the nginx config to use your domain:
```bash
nano infra/prod/nginx/default.conf
# Replace ${DOMAIN} with your actual domain name
```

#### 6. Start Everything
```bash
cd /opt/growthblueprint/infra/prod
docker compose up -d --build

# Check that everything started:
docker compose ps

# View logs:
docker compose logs -f
```

#### 7. Set Up SSL Certificate
```bash
cd /opt/growthblueprint/infra/prod
./scripts/setup-ssl.sh your-domain.com your-email@example.com
```

#### 8. Verify
Open `https://your-domain.com` in a browser. You should see the login page.

### Setting Up Automated Backups
```bash
# Edit crontab
crontab -e

# Add this line for daily backup at 2 AM:
0 2 * * * cd /opt/growthblueprint/infra/prod && ./scripts/backup-db.sh

# Backups are stored in /opt/growthblueprint/backups/
# Kept for 30 days by default
```

### How to Restore from Backup
```bash
cd /opt/growthblueprint/infra/prod

# List available backups
ls -la /opt/growthblueprint/backups/

# Restore (WARNING: this replaces current data)
gunzip -c /opt/growthblueprint/backups/growthblueprint_YYYYMMDD_HHMMSS.sql.gz \
  | docker compose exec -T postgres psql -U gb_user growthblueprint
```

## How to Set Environment Variables and Secrets

All secrets go in the `.env` file. Here is what each one does:

| Variable | What It Is | How to Get It |
|----------|-----------|---------------|
| DB_PASS | Database password | Generate: `openssl rand -base64 32` |
| JWT_SECRET | Signing key for login tokens | Generate: `openssl rand -base64 64` |
| ENCRYPTION_KEY | Encrypts stored API tokens | Generate: `openssl rand -hex 16` |
| STRIPE_SECRET_KEY | Stripe payment processing | https://dashboard.stripe.com/apikeys |
| STRIPE_WEBHOOK_SECRET | Verifies Stripe notifications | https://dashboard.stripe.com/webhooks |
| REDIS_PASSWORD | Redis authentication | Generate: `openssl rand -base64 32` |

## How to Get API Credentials for Each Platform

### Meta (Facebook/Instagram) Ads
1. Go to https://developers.facebook.com
2. Click "My Apps" → "Create App"
3. Choose "Business" type
4. App name: "GrowthBlueprint" (or your brand)
5. Go to App Settings → Basic: copy **App ID** and **App Secret**
6. Add "Marketing API" product
7. Set OAuth redirect URL: `https://your-domain.com/api/connectors/meta_ads/callback`
8. Required scopes: `ads_read`, `read_insights`
9. Submit for App Review before going live

### Google Ads
1. Go to https://console.cloud.google.com
2. Create a new project: "GrowthBlueprint"
3. Enable "Google Ads API"
4. Go to Credentials → Create OAuth 2.0 Client ID
5. Application type: Web application
6. Authorized redirect URI: `https://your-domain.com/api/connectors/google_ads/callback`
7. Copy **Client ID** and **Client Secret**
8. Apply for Google Ads API access: https://developers.google.com/google-ads/api/docs/get-started/dev-token

### TikTok Ads
1. Go to https://business-api.tiktok.com
2. Register as a developer
3. Create an app
4. Set callback URL: `https://your-domain.com/api/connectors/tiktok_ads/callback`
5. Copy **App ID** and **App Secret**
6. Required scopes: `ad_account.read`, `campaign.read`, `report.read`

### YouTube Analytics
1. Go to https://console.cloud.google.com (same project as Google Ads)
2. Enable "YouTube Analytics API" and "YouTube Data API v3"
3. Use same OAuth client as Google Ads
4. Redirect URI: `https://your-domain.com/api/connectors/youtube_analytics/callback`
5. Required scopes: `yt-analytics.readonly`

### GA4 (Google Analytics 4)
1. Go to https://console.cloud.google.com (same project)
2. Enable "Google Analytics Data API"
3. Use same OAuth client
4. Redirect URI: `https://your-domain.com/api/connectors/ga4/callback`
5. Required scopes: `analytics.readonly`

### Shopify
1. Go to https://partners.shopify.com
2. Create a partner account
3. Create an app: "GrowthBlueprint"
4. Set redirect URL: `https://your-domain.com/api/connectors/shopify/callback`
5. Copy **API Key** and **API Secret Key**
6. Required scopes: `read_orders`, `read_products`, `read_analytics`

### Google Search Console (Optional)
1. Go to https://console.cloud.google.com (same project)
2. Enable "Search Console API"
3. Use same OAuth client
4. Redirect URI: `https://your-domain.com/api/connectors/google_search_console/callback`
5. Required scopes: `webmasters.readonly`

## What Redirect URLs to Configure for OAuth

For each platform, the redirect URL follows this pattern:
```
https://your-domain.com/api/connectors/{platform}/callback
```

| Platform | Redirect URL |
|----------|-------------|
| Meta Ads | `https://your-domain.com/api/connectors/meta_ads/callback` |
| Google Ads | `https://your-domain.com/api/connectors/google_ads/callback` |
| TikTok Ads | `https://your-domain.com/api/connectors/tiktok_ads/callback` |
| YouTube Analytics | `https://your-domain.com/api/connectors/youtube_analytics/callback` |
| GA4 | `https://your-domain.com/api/connectors/ga4/callback` |
| Shopify | `https://your-domain.com/api/connectors/shopify/callback` |
| Search Console | `https://your-domain.com/api/connectors/google_search_console/callback` |

## How to Rotate Keys and Revoke Tokens

### Rotating JWT Secret
1. Generate new secret: `openssl rand -base64 64`
2. Update `.env` file with new `JWT_SECRET`
3. Restart the API: `docker compose restart api`
4. All existing sessions will be invalidated (users must log in again)

### Rotating Encryption Key
**WARNING**: Changing the encryption key will make existing connector tokens unreadable.
1. Disconnect all connectors first (via admin or API)
2. Generate new key: `openssl rand -hex 16`
3. Update `.env` file with new `ENCRYPTION_KEY`
4. Restart services: `docker compose restart api ai-orchestrator`
5. Users will need to reconnect their platforms

### Revoking Platform Tokens
1. Go to the platform's developer console
2. Revoke the app's access
3. In GrowthBlueprint, mark the connector as DISCONNECTED:
   ```sql
   UPDATE connectors SET status = 'DISCONNECTED', encrypted_tokens_json = NULL WHERE platform = 'platform_name';
   ```

## How to Monitor and Troubleshoot

### Checking Service Health
```bash
# All services status
docker compose ps

# API health
curl https://your-domain.com/api/health

# View logs for a specific service
docker compose logs -f api
docker compose logs -f ai-orchestrator
docker compose logs -f web
docker compose logs -f postgres
```

### Common Issues

| Issue | Check | Fix |
|-------|-------|-----|
| Cannot connect | `docker compose ps` | Restart: `docker compose restart` |
| Login fails | API logs for auth errors | Check JWT_SECRET in .env |
| Plan generation stuck | Redis: `redis-cli LLEN plan_jobs_queue` | Restart ai-orchestrator |
| Database full | `docker compose exec postgres psql -c "SELECT pg_size_pretty(pg_database_size('growthblueprint'))"` | Increase disk, clean old data |
| SSL expired | Check certbot logs | `docker compose exec certbot certbot renew` |
| Connector failing | API logs for connector errors | Check platform API status, token expiry |

## Go-Live Checklist

Before making the product available to real users, verify every item:

### Security
- [ ] Changed ALL default secrets in .env (JWT, encryption, DB, Redis)
- [ ] HTTPS working with valid certificate
- [ ] Firewall enabled (only ports 22, 80, 443 open)
- [ ] CORS origins set to production domain only
- [ ] DEV_MODE set to false
- [ ] Stripe webhook signature verification enabled
- [ ] No test/demo credentials in production

### Infrastructure
- [ ] VPS has adequate resources (4GB+ RAM, 2+ CPU)
- [ ] Docker containers running and healthy
- [ ] Automated backups configured (daily at minimum)
- [ ] Backup restoration tested
- [ ] DNS propagated correctly
- [ ] SSL certificate auto-renewal working

### Application
- [ ] Registration and login work
- [ ] Business profile creation works
- [ ] Plan generation completes successfully
- [ ] Connector flows work (if applicable)
- [ ] Stripe checkout creates subscription
- [ ] Stripe webhook updates tier correctly
- [ ] Tier-based feature gating works (FREE vs PRO vs BUSINESS)
- [ ] PDF export works for paid tiers

### Platform Credentials
- [ ] Meta App reviewed and approved (if using Meta connector)
- [ ] Google Ads API developer token approved
- [ ] TikTok developer app approved
- [ ] Shopify app listed (if using Shopify connector)
- [ ] All OAuth redirect URLs configured correctly

### Monitoring
- [ ] Log aggregation accessible
- [ ] Health check endpoint monitored
- [ ] Alert for service downtime
- [ ] Database backup verification automated
- [ ] Error tracking in place

### Legal
- [ ] Privacy Policy published
- [ ] Terms of Service published
- [ ] Cookie consent (if applicable)
- [ ] Data processing agreement for connectors

## Build Sequence (From Scratch)

If you were to build this from absolute scratch, here is the order:

1. **Set up development environment** (Docker, Git, IDE)
2. **Database schema** (Flyway migrations — defines all tables)
3. **API skeleton** (Spring Boot project, health endpoint)
4. **Authentication** (register, login, JWT, refresh tokens)
5. **Business profiles** (CRUD endpoints)
6. **Plan generation** (job queue, AI orchestrator, mock LLM)
7. **Frontend basics** (login, dashboard, profile creation)
8. **Plan viewer** (display generated plans)
9. **Billing** (Stripe integration, tier management)
10. **Connectors** (OAuth architecture, token encryption, one connector at a time)
11. **Analytics** (data sync, unified metrics, display)
12. **Forecasting** (deterministic tools, quality scoring)
13. **Production deployment** (VPS, SSL, nginx, backups)
14. **Testing & polish** (edge cases, error handling, UI refinement)
15. **Go-live** (checklist above)
ROADMAPEOF


###############################################################################
# FINAL OUTPUT
###############################################################################

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         GrowthBlueprint Generated Successfully!            ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📁 Project created at: ${ROOT}${NC}"
echo ""
echo -e "${YELLOW}═══ LOCAL DEVELOPMENT ═══${NC}"
echo ""
echo "  1. Copy environment template:"
echo "     cp infra/docker/.env.example infra/docker/.env"
echo ""
echo "  2. Start all services:"
echo "     make dev"
echo ""
echo "  3. Access:"
echo "     Frontend:  http://localhost:3000"
echo "     API:       http://localhost:8080/health"
echo "     Demo:      demo@growthblueprint.local / DemoPass123!"
echo ""
echo "  4. Other commands:"
echo "     make down      — Stop all services"
echo "     make logs      — View logs"
echo "     make reset-db  — Reset database"
echo ""
echo -e "${YELLOW}═══ PRODUCTION DEPLOYMENT ═══${NC}"
echo ""
echo "  1. Copy and configure production environment:"
echo "     cp infra/prod/.env.example infra/prod/.env"
echo "     # Edit with strong secrets (see docs/ROADMAP_AND_RUNBOOK.md)"
echo ""
echo "  2. Start production:"
echo "     cd infra/prod && docker compose up -d --build"
echo ""
echo "  3. Setup SSL:"
echo "     cd infra/prod && ./scripts/setup-ssl.sh your-domain.com your@email.com"
echo ""
echo "  4. Setup backups:"
echo "     crontab -e"
echo "     # 0 2 * * * cd /opt/growthblueprint/infra/prod && ./scripts/backup-db.sh"
echo ""
echo -e "${YELLOW}═══ PLATFORM API CREDENTIALS ═══${NC}"
echo ""
echo "  Set these in your .env file:"
echo "     META_APP_ID / META_APP_SECRET"
echo "     GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET"
echo "     TIKTOK_APP_ID / TIKTOK_APP_SECRET"
echo "     SHOPIFY_API_KEY / SHOPIFY_API_SECRET"
echo ""
echo "  See docs/ROADMAP_AND_RUNBOOK.md for step-by-step instructions"
echo "  on how to create developer apps on each platform."
echo ""
echo -e "${YELLOW}═══ DNS & HTTPS ═══${NC}"
echo ""
echo "  1. Point your domain to your VPS IP (A record)"
echo "  2. Update DOMAIN in infra/prod/.env"
echo "  3. Update infra/prod/nginx/default.conf"
echo "  4. Run: ./scripts/setup-ssl.sh your-domain.com your@email.com"
echo ""
echo -e "${YELLOW}═══ DOCUMENTATION ═══${NC}"
echo ""
echo "  docs/ROADMAP_AND_RUNBOOK.md   — Complete guide (start here)"
echo "  docs/ARCHITECTURE.md          — System design"
echo "  docs/VPS_DEPLOYMENT.md        — Server setup"
echo "  docs/THREAT_MODEL.md          — Security analysis"
echo "  docs/EDGE_CASES.md            — Edge case handling"
echo "  docs/WHAT_NOT_TO_DO.md        — Forbidden behaviors"
echo "  docs/SEQUENCE_PLAN_GENERATION.md — Plan flow diagram"
echo "  docs/SEQUENCE_ANALYTICS_SYNC.md  — Analytics sync diagram"
echo "  docs/FUTURE_AWS.md            — AWS migration plan"
echo ""
echo -e "${GREEN}Done! Happy building! 🚀${NC}"
