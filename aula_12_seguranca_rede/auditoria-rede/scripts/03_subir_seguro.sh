#!/usr/bin/env bash
# PASSO 3 - Sobe o cenario SEGURO (estado-alvo apos a refatoracao).
# EVIDENCIA 3: docker compose ps mostrando que SOMENTE o proxy publica porta no host.
# Banco e cache ficam na backend-net (internal: true), sem porta mapeada.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f .env ] || cp .env.example .env

echo "===== Derrubando o cenario inseguro (se estiver no ar) ====="
docker compose -f docker-compose.inseguro.yml down -v >/dev/null 2>&1 || true

echo "===== Subindo o cenario SEGURO (2 redes + exposicao minima) ====="
docker compose -f docker-compose.seguro.yml up -d

echo
echo "===== docker compose ps (apenas o proxy deve publicar porta) ====="
docker compose -f docker-compose.seguro.yml ps

echo
echo ">>> Observe: db e cache SEM coluna de portas publicadas. Unica porta no host: 8080 (proxy)."
echo ">>> Rode 04_validar_isolamento.sh para provar o isolamento."
