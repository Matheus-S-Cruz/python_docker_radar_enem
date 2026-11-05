#!/usr/bin/env bash
# EVIDENCIA 1 - Inspecao da rede interna backend-net.
# Deve mostrar: subnet 172.20.20.0/24, "Internal": true e os IPs de radar-backend e radar-db.
set -euo pipefail

echo "===== docker network inspect radar-enem-network_backend-net ====="
docker network inspect radar-enem-network_backend-net

echo
echo "===== Resumo (CIDR / Internal / Containers e IPs) ====="
docker network inspect radar-enem-network_backend-net \
  --format 'Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}} | Internal: {{.Internal}}'
docker network inspect radar-enem-network_backend-net \
  --format '{{range $id, $c := .Containers}}{{$c.Name}} -> {{$c.IPv4Address}}{{"\n"}}{{end}}'
