# Evidencias — Aula 11 (Redes e Containers)

Salve aqui os prints de tela e/ou os `.txt` gerados pelo laboratorio. Entregaveis exigidos pelo AVA:

| Arquivo sugerido | Conteudo (o que o print deve mostrar) | Status |
|---|---|---|
| `inspecao_rede_1.png` + `inspecao_rede_2.png` | `docker network inspect radar-enem-network_backend-net`: CIDR `172.20.20.0/24`, `"Internal": true` e os IPs de `radar-backend` e `radar-db`. | ✅ ja capturado |
| `02_isolamento.png` | Proxy OK em `localhost:8080`; falha `radar-proxy -> radar-db`; sucesso `radar-backend -> radar-db`. | ⬜ RECAPTURAR (script corrigido) |
| `03_desafios.png` | Os 4 desafios: resolucao de nome, `ip route show`, teste de desconexao (erro de gateway) e acesso via Bastion Host. | ⬜ RECAPTURAR (script corrigido) |
| `04_diagrama_vpc.png` | Diagrama da VPC `10.20.0.0/16` (3 sub-redes, CIDRs, IGW, NAT GW e setas de trafego). | ✅ gerado a partir do SVG |
| `01_passo1_redes_manuais.png` (opcional) | Passo 1: criacao/inspecao (IPAM)/remocao manual das redes antes do Compose. | ⬜ opcional |

> **Importante (bug corrigido):** as capturas antigas de isolamento/desafios usavam `nslookup`,
> que no Codespaces concatena o *search domain* (`*.cx.internal.cloudapp.net`) e retornava
> `NXDOMAIN` ate para nomes que o DNS do Docker resolve. Os scripts agora usam `getent hosts`,
> que consulta o resolver do Docker (`127.0.0.11`) corretamente. Por isso as capturas
> `02_isolamento.png` e `03_desafios.png` precisam ser **refeitas** com os scripts atualizados.

> O script `scripts/05_capturar_evidencias.sh` tambem gera versoes em `.txt`
> (`evidencia1_inspecao_rede.txt`, `evidencia2_isolamento.txt`, `evidencia3_desafios.txt`)
> caso voce queira anexar as saidas em texto alem dos prints.
