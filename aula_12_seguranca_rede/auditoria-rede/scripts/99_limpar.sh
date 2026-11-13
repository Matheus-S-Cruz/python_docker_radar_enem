#!/usr/bin/env bash
# PASSO 99 - Limpeza: derruba os dois cenarios e remove volumes.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

echo "===== Derrubando cenario INSEGURO ====="
docker compose -f docker-compose.inseguro.yml down -v || true

echo "===== Derrubando cenario SEGURO ====="
docker compose -f docker-compose.seguro.yml down -v || true

echo ">>> Ambiente limpo."
