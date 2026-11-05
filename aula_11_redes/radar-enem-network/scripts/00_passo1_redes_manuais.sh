#!/usr/bin/env bash
# PASSO 1 - Criacao manual das redes isoladas (executar ANTES do docker compose).
# Objetivo: entender IPAM e isolamento criando/inspecionando/removendo as redes na mao.
set -euo pipefail

echo "===== 1. Cria a rede publica/DMZ (frontend-net) ====="
docker network create --driver bridge --subnet 172.20.10.0/24 frontend-net

echo
echo "===== 2. Cria a rede isolada interna (backend-net, internal) ====="
docker network create --driver bridge --internal --subnet 172.20.20.0/24 backend-net

echo
echo "===== 3. Lista redes e inspeciona a tabela IPAM da rede interna ====="
docker network ls
docker network inspect backend-net

echo
echo "===== 4. Remove as redes manuais (o Compose vai recriar a topologia no Passo 2) ====="
docker network rm frontend-net backend-net

echo
echo "Passo 1 concluido. Agora rode: docker compose up -d"
