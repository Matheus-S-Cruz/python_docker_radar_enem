#!/usr/bin/env bash
# EVIDENCIA 2 - Testes de isolamento (Passo 5).
# Demonstra:
#   (a) Proxy publico funcionando em localhost:8080
#   (b) FALHA de comunicacao radar-proxy -> radar-db (proxy nao esta na backend-net)
#   (c) SUCESSO de comunicacao radar-backend -> radar-db (backend e multi-homed)
set -euo pipefail

echo "===== (a) Teste 1: Acesso externo via Proxy (localhost:8080) ====="
curl -i http://localhost:8080
echo

echo "===== (b) Teste 2: radar-proxy -> radar-db  (DEVE FALHAR) ====="
echo "--- nslookup radar-db a partir do proxy (nao resolve: proxy nao ve a backend-net) ---"
docker exec radar-proxy nslookup radar-db || echo ">>> Como esperado: o proxy NAO resolve radar-db."
echo
echo "--- tentativa de conexao TCP proxy -> 172.20.20.50:5432 (nc, timeout 5s) ---"
if docker exec radar-proxy sh -c "which nc >/dev/null 2>&1"; then
  docker exec radar-proxy sh -c "nc -z -w 5 172.20.20.50 5432" \
    && echo ">>> INESPERADO: conectou." \
    || echo ">>> Como esperado: o proxy NAO alcanca o banco (sem rota para a backend-net)."
else
  echo "(nc indisponivel no proxy; a falha de DNS acima ja comprova o isolamento)"
fi
echo

echo "===== (c) Teste 3: radar-backend -> radar-db  (DEVE FUNCIONAR) ====="
echo "--- nslookup radar-db a partir do backend (resolve: backend esta na backend-net) ---"
docker exec radar-backend nslookup radar-db || true
echo
echo "--- conexao TCP backend -> 172.20.20.50:5432 ---"
docker exec radar-backend sh -c "nc -z -w 5 172.20.20.50 5432 && echo '>>> SUCESSO: backend alcanca o banco na porta 5432.'" \
  || echo ">>> Falhou (verifique se o banco subiu)."
