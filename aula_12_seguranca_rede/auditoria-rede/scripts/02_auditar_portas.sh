#!/usr/bin/env bash
# PASSO 2 - Auditoria de portas do cenario INSEGURO (a FOTO do risco).
# EVIDENCIA 2: prova que, do ponto de vista do host (= internet no modelo 0.0.0.0/0),
# as portas sensiveis respondem. Usa nmap se disponivel; senao, cai para nc (netcat).
set -uo pipefail   # sem -e: os testes de porta podem "falhar" e isso faz parte da leitura
cd "$(dirname "$0")/.." || exit 1

PORTAS=(8080 8081 5432 6379)

echo "===== Auditoria de exposicao de portas no host (127.0.0.1) ====="
echo "Camadas: 8080=frontend  8081=backend-api  5432=PostgreSQL  6379=Redis"
echo

if command -v nmap >/dev/null 2>&1; then
  echo "--- nmap -sT -p 8080,8081,5432,6379 127.0.0.1 ---"
  nmap -sT -p 8080,8081,5432,6379 127.0.0.1
else
  echo "[info] nmap nao encontrado; tentando instalar (sudo apt-get)..."
  if command -v sudo >/dev/null 2>&1 && sudo apt-get update -qq >/dev/null 2>&1 \
     && sudo apt-get install -y -qq nmap >/dev/null 2>&1; then
    echo "--- nmap -sT -p 8080,8081,5432,6379 127.0.0.1 ---"
    nmap -sT -p 8080,8081,5432,6379 127.0.0.1
  else
    echo "[info] seguindo com nc (netcat) como alternativa portavel:"
    for p in "${PORTAS[@]}"; do
      if nc -z -w 3 127.0.0.1 "$p" 2>/dev/null; then
        echo "  porta $p/tcp  ->  ABERTA (responde no host)"
      else
        echo "  porta $p/tcp  ->  fechada/sem resposta"
      fi
    done
  fi
fi

echo
echo "===== PARECER DA AUDITORIA ====="
echo ">>> 5432 (PostgreSQL) e 6379 (Redis) ABERTAS no host = acesso direto da internet."
echo ">>> Redis, por padrao, NAO exige autenticacao -> leitura/escrita do cache por qualquer um."
echo ">>> PostgreSQL exposto -> alvo de forca bruta e exploracao de CVEs. FALHAS R-03 e R-04."
