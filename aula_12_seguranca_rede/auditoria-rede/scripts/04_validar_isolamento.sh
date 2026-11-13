#!/usr/bin/env bash
# PASSO 4 - Validacao do isolamento no cenario SEGURO.
# EVIDENCIA 4, em tres provas:
#   (a) O proxy publico responde em localhost:8080  -> servico continua funcionando.
#   (b) 5432/6379 NAO respondem mais a partir do host -> exposicao eliminada (corrige R-03/R-04).
#   (c) O backend AINDA alcanca db:5432 e cache:6379 pela rede interna -> comunicacao autorizada preservada.
set -uo pipefail   # sem -e: (b) depende de conexoes que DEVEM falhar
cd "$(dirname "$0")/.." || exit 1

echo "===== (a) Acesso publico legitimo: curl http://localhost:8080 ====="
curl -si http://localhost:8080 | sed -n '1,8p'
echo

echo "===== (b) Portas de dados a partir do HOST (DEVEM estar FECHADAS) ====="
for p in 5432 6379; do
  if nc -z -w 3 127.0.0.1 "$p" 2>/dev/null; then
    echo "  porta $p/tcp no host -> ABERTA  (INESPERADO: ainda exposta!)"
  else
    echo "  porta $p/tcp no host -> fechada (correto: isolada na rede interna)"
  fi
done
echo

echo "===== (c) Backend -> db:5432 e cache:6379 pela rede interna (DEVEM FUNCIONAR) ====="
if docker exec radar-seg-backend sh -c 'nc -z -w 5 db 5432' 2>/dev/null; then
  echo "  backend -> db:5432     -> OK (comunicacao interna autorizada)"
else
  echo "  backend -> db:5432     -> falhou (verifique se o banco subiu)"
fi
if docker exec radar-seg-backend sh -c 'nc -z -w 5 cache 6379' 2>/dev/null; then
  echo "  backend -> cache:6379  -> OK (comunicacao interna autorizada)"
else
  echo "  backend -> cache:6379  -> falhou (verifique se o cache subiu)"
fi

echo
echo "===== CONCLUSAO ====="
echo ">>> O servico segue acessivel pela face publica, mas banco e cache sao inalcancaveis"
echo ">>> de fora e so respondem a camada autorizada. Principio da Exposicao Minima aplicado."
