#!/usr/bin/env bash
# EVIDENCIA 3 - Os 4 Desafios Investigativos (Passo 6).
# Rode este script com o ambiente no ar (apos 01_subir_ambiente.sh).
#
# NOTA sobre resolucao de nomes:
#   O nslookup do busybox concatena o "search domain" do Codespaces e pode retornar
#   NXDOMAIN ate para nomes validos. Mostramos o nslookup (conforme o enunciado) e o
#   /etc/resolv.conf (prova que o DNS do Docker e o 127.0.0.11), mas a prova definitiva
#   de ESCOPO e feita pela CONEXAO via NOME (nc -z radar-backend 80 / nc -z radar-db 5432):
#   o proxy so conecta a quem compartilha rede com ele.
set -uo pipefail   # sem -e: os desafios incluem comandos que FALHAM de proposito

NET_FRONT="radar-enem-network_frontend-net"
NET_BACK="radar-enem-network_backend-net"

echo "############################################################"
echo "# DESAFIO 1 - Escopo do DNS interno do Docker"
echo "############################################################"
echo "--- /etc/resolv.conf do proxy (deve apontar o DNS embutido 127.0.0.11) ---"
docker exec radar-proxy cat /etc/resolv.conf
echo
echo "--- nslookup radar-backend a partir do proxy (DEVE resolver: mesmo escopo frontend-net) ---"
docker exec radar-proxy nslookup radar-backend 2>&1 | sed -n '1,8p' || true
echo
echo "--- nslookup radar-db a partir do proxy (NAO deve resolver: banco so existe na backend-net) ---"
docker exec radar-proxy nslookup radar-db 2>&1 | sed -n '1,8p' || echo "(NXDOMAIN - esperado)"
echo
echo ">>> NOTA: o nslookup do busybox acrescenta o 'search domain' do Codespaces ao nome;"
echo ">>> por isso a prova definitiva de ESCOPO e feita pela conexao via NOME abaixo:"
echo "--- nc -z -v -w5 radar-backend 80 (a partir do proxy: DEVE conectar) ---"
docker exec radar-proxy nc -z -v -w 5 radar-backend 80 2>&1 \
  && echo ">>> SUCESSO: proxy descobre radar-backend pelo nome (frontend-net compartilhada)." \
  || echo ">>> INESPERADO: proxy nao alcancou radar-backend."
echo "--- nc -z -v -w5 radar-db 5432 (a partir do proxy: NAO deve conectar) ---"
docker exec radar-proxy nc -z -v -w 5 radar-db 5432 2>&1 \
  && echo ">>> INESPERADO: proxy alcancou radar-db." \
  || echo ">>> Esperado: proxy NAO descobre/alcanca radar-db (fora do escopo da backend-net)."
echo

echo "############################################################"
echo "# DESAFIO 2 - Multi-homing e tabela de rotas do backend"
echo "############################################################"
echo "--- ip addr show (duas interfaces: eth0 e eth1) ---"
docker exec radar-backend ip addr show
echo
echo "--- ip route show (qual interface tem a rota default?) ---"
docker exec radar-backend ip route show
echo ">>> A rota default sai pela interface da frontend-net (bridge NAO internal),"
echo ">>> pois a backend-net (internal:true) nao possui gateway para fora."
echo

echo "############################################################"
echo "# DESAFIO 3 - Chaos: queda da rota publica do backend -> erro de gateway"
echo "############################################################"
echo "--- Desconectando radar-backend da frontend-net ---"
docker network disconnect "$NET_FRONT" radar-backend
echo
echo "--- Acesso ao proxy agora (ESPERADO: 502/504 - erro de gateway) ---"
curl -si http://localhost:8080 | sed -n '1,10p' || true
echo
echo "--- Log de erro do proxy (ultimas linhas) ---"
docker logs --tail 10 radar-proxy
echo
echo "--- Restaurando a conectividade SEM reiniciar os containers ---"
docker network connect --ip 172.20.10.20 "$NET_FRONT" radar-backend
sleep 2
echo "--- Acesso ao proxy restaurado (ESPERADO: 200 OK) ---"
curl -si http://localhost:8080 | sed -n '1,20p' || true
echo

echo "############################################################"
echo "# DESAFIO 4 - Acesso admin via container Bastion Host (jumpbox)"
echo "############################################################"
echo "--- Container efemero na backend-net consultando o banco (psql \\l) ---"
docker run --rm --network "$NET_BACK" \
  -e PGPASSWORD=enem_secret_2026 \
  postgres:15-alpine \
  psql -h 172.20.20.50 -U radar_admin -d radarenem -c "\l"
echo
echo ">>> Mesmo sem a porta 5432 exposta no host, o bastion conectado a backend-net"
echo ">>> alcanca o PostgreSQL diretamente pela rede interna."
