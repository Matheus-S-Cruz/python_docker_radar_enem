#!/usr/bin/env bash
# Executado automaticamente pelo Codespaces apos criar o container.
# Deixa o ambiente pronto para o laboratorio da Aula 11.
set -euo pipefail

echo "===== Verificando Docker ====="
docker --version || true
docker compose version || true

LAB="aula_11_redes/radar-enem-network"
if [ -d "$LAB/scripts" ]; then
  echo "===== Ajustando permissoes dos scripts da Aula 11 ====="
  chmod +x "$LAB"/scripts/*.sh
  echo "Scripts prontos em $LAB/scripts/"
fi

echo
echo "Ambiente pronto! Para rodar o laboratorio da Aula 11:"
echo "  cd $LAB"
echo "  bash scripts/01_subir_ambiente.sh"
