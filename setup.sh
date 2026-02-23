#!/usr/bin/env bash
set -euo pipefail

: "${OPENAI_API_KEY:?OPENAI_API_KEY must be set}"

mvn -B clean package

docker compose up --build -d

echo "strategy-service is running on http://localhost:${SERVER_PORT:-8080}"
