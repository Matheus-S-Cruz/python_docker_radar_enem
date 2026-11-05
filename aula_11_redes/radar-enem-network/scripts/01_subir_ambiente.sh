#!/usr/bin/env bash
# PASSO 2/5 - Sobe o ambiente com Docker Compose e aguarda o banco ficar pronto.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "===== Subindo o ambiente (docker compose up -d) ====="
docker compose up -d

echo
echo "===== Aguardando o PostgreSQL aceitar conexoes ====="
for i in $(seq 1 30); do
  if docker exec radar-db pg_isready -U radar_admin -d radarenem >/dev/null 2>&1; then
    echo "radar-db pronto."
    break
  fi
  echo "  aguardando banco... ($i/30)"
  sleep 2
done

echo
echo "===== Status dos containers ====="
docker compose ps
