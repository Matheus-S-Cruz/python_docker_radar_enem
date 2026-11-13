#!/usr/bin/env bash
# PASSO 1 - Sobe o cenario INSEGURO (o problema a ser auditado).
# EVIDENCIA 1: docker compose ps mostrando TODAS as portas mapeadas no host,
# inclusive 5432 (banco) e 6379 (cache) -- a exposicao indevida das regras R-03 e R-04.
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f .env ] || cp .env.example .env

echo "===== Subindo o cenario INSEGURO (rede unica + tudo exposto) ====="
docker compose -f docker-compose.inseguro.yml up -d

echo
echo "===== docker compose ps (observe as portas publicadas no host) ====="
docker compose -f docker-compose.inseguro.yml ps

echo
echo ">>> ATENCAO: 5432/tcp (PostgreSQL) e 6379/tcp (Redis) estao abertos para o host."
echo ">>> Isso espelha as regras R-03 e R-04 liberando 0.0.0.0/0. Rode 02_auditar_portas.sh."
