# Evidencias — Aula 11 (Redes e Containers)

Salve aqui os prints de tela e/ou os `.txt` gerados pelo laboratorio. Entregaveis exigidos pelo AVA:

| Arquivo sugerido | Conteudo (o que o print deve mostrar) |
|---|---|
| `01_inspecao_backend_net.png` | `docker network inspect radar-enem-network_backend-net`: CIDR `172.20.20.0/24`, `"Internal": true` e os IPs de `radar-backend` e `radar-db`. |
| `02_isolamento.png` | Proxy OK em `localhost:8080`; falha `radar-proxy -> radar-db`; sucesso `radar-backend -> radar-db`. |
| `03_desafios.png` | Os 4 desafios: `nslookup`, `ip route show`, teste de desconexao (502) e acesso via Bastion Host. |
| `04_diagrama_vpc.png` | Diagrama da VPC `10.20.0.0/16` (3 sub-redes, CIDRs, IGW, NAT GW e setas de trafego). |

> O script `scripts/05_capturar_evidencias.sh` tambem gera versoes em `.txt`
> (`evidencia1_inspecao_rede.txt`, `evidencia2_isolamento.txt`, `evidencia3_desafios.txt`)
> caso voce queira anexar as saidas em texto alem dos prints.
