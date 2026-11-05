#!/usr/bin/env bash
# EVIDENCIA 2 - Testes de isolamento (Passo 5).
# Demonstra:
#   (a) Proxy publico funcionando em localhost:8080
#   (b) FALHA de comunicacao radar-proxy -> radar-db (proxy nao esta na backend-net)
#   (c) SUCESSO de comunicacao radar-backend -> radar-db (backend e multi-homed)
#
# NOTA sobre resolucao de nomes:
#   O nslookup do busybox concatena o "search domain" injetado pelo Codespaces
#   (ex.: *.cx.internal.cloudapp.net) e pode retornar NXDOMAIN ate para nomes que o
#   DNS do Docker resolve. Por isso a prova de "descoberta de servico" aqui e feita
#   pela CONEXAO REAL usando o NOME do container (nc -z radar-db 5432): se conecta,
#   e porque o nome resolveu (DNS 127.0.0.11) E existe rota ate ele. Isso evita o
#   artefato do nslookup e demonstra o isolamento de forma inequivoca.
set -uo pipefail   # sem -e: o item (b) inclui comandos que FALHAM de proposito

echo "===== (a) Teste 1: Acesso externo via Proxy (localhost:8080) ====="
curl -si http://localhost:8080 | sed -n '1,20p'
echo

echo "===== (b) Teste 2: radar-proxy -> radar-db  (DEVE FALHAR) ====="
echo "--- nc -z -v -w5 radar-db 5432 a partir do proxy (resolucao+conexao pelo NOME) ---"
if docker exec radar-proxy nc -z -v -w 5 radar-db 5432 2>&1; then
  echo ">>> INESPERADO: o proxy alcancou radar-db."
else
  echo ">>> Como esperado: o proxy NAO descobre nem alcanca radar-db"
  echo ">>> (nome fora do escopo da backend-net e sem rota ate a rede interna)."
fi
echo

echo "===== (c) Teste 3: radar-backend -> radar-db  (DEVE FUNCIONAR) ====="
echo "--- nc -z -v -w5 radar-db 5432 a partir do backend (resolucao+conexao pelo NOME) ---"
if docker exec radar-backend nc -z -v -w 5 radar-db 5432 2>&1; then
  echo ">>> SUCESSO: backend descobre radar-db pelo nome e conecta na porta 5432"
  echo ">>> (backend e multi-homed: participa da backend-net)."
else
  echo ">>> Falhou (verifique se o banco subiu)."
fi
