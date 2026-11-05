#!/usr/bin/env bash
# Derruba o ambiente e remove as redes/volumes criados pelo projeto.
set -uo pipefail
cd "$(dirname "$0")/.."
docker compose down -v
echo "Ambiente removido."
