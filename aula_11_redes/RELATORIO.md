# Relatório Técnico — Aula 11

## Redes e Containers com Docker — Mini Radar ENEM

**Disciplina:** Computação em Nuvem
**Atividade:** Aula 11 — Isolamento de serviços e roteamento (hands-on)
**Projeto base:** Mini Radar ENEM

---

## 1. Desafios investigativos (Passo 6)

> Preencha as saídas reais com as evidências capturadas no Codespace (ver `README.md`). Abaixo,
> a explicação técnica esperada para cada desafio.

### Desafio 1 — Escopo do DNS interno do Docker

Comandos: `cat /etc/resolv.conf`, `nslookup radar-backend`, `nslookup radar-db` (a partir do `radar-proxy`).

- O `/etc/resolv.conf` do `radar-proxy` aponta para o **DNS embutido do Docker em `127.0.0.11`**.
- `nslookup radar-backend` **resolve**, porque proxy e backend compartilham a `frontend-net`.
- `nslookup radar-db` **não resolve** (NXDOMAIN): o banco só existe na `backend-net`, da qual o
  proxy não participa. O DNS interno do Docker é **escopado por rede** — um container só descobre
  pelo nome os serviços que estão em alguma rede comum a ele.

### Desafio 2 — Multi-homing e tabela de rotas

Comandos: `ip addr show`, `ip route show` (dentro de `radar-backend`).

- `radar-backend` tem **duas interfaces**: `eth0` e `eth1` (uma por rede).
- A **rota default (`default via ...`) sai pela interface da `frontend-net`**. Motivo: a
  `backend-net` é `internal: true`, ou seja, **não tem gateway para fora**; o Docker só configura
  gateway/rota padrão pela rede bridge comum (não-internal). Por isso o tráfego "para o mundo"
  do backend segue pela frontend-net.

### Desafio 3 — Chaos: queda da rota pública e erro 502

- Ao executar `docker network disconnect radar-enem-network_frontend-net radar-backend`, o proxy
  perde o caminho até o backend. O acesso a `localhost:8080` passa a retornar um **erro de gateway**
  (`502 Bad Gateway` quando a conexão é recusada, ou `504 Gateway Time-out` quando ela estoura o
  `proxy_connect_timeout` — ambos indicam que o upstream ficou inacessível) e o log do proxy registra
  algo como *"connect() failed"/"upstream timed out"* para `radar-backend`.
- `docker network connect --ip 172.20.10.20 radar-enem-network_frontend-net radar-backend`
  **restaura a conectividade sem reiniciar** os containers — o próximo request volta a **200 OK**.

### Desafio 4 — Bastion Host (jumpbox)

- Mesmo com a porta `5432` **não publicada** no host, um container efêmero (`--rm`) conectado
  diretamente à `backend-net` alcança o PostgreSQL em `172.20.20.50` e executa `psql ... -c "\l"`.
- Equivale a um **Bastion Host / AWS Systems Manager Session Manager**: manutenção e auditoria
  seguras na sub-rede privada, sem abrir o banco para o host ou para a internet.

---

## 2. Incremento 4 — Arquitetura de rede em nuvem (VPC `10.20.0.0/16`)

### 2.1. Plano de endereçamento e sub-redes

| Componente / Camada | CIDR | IPs (totais / úteis) | Tipo de sub-rede | Finalidade |
|---|---|---|---|---|
| Entrada / Load Balancer | `10.20.1.0/24` | 256 / 251 | Pública | Receber tráfego HTTPS externo dos usuários e hospedar o NAT Gateway. |
| Backend Radar ENEM | `10.20.2.0/24` | 256 / 251 | Privada (saída via NAT) | Executar a API e o motor estatístico de diagnósticos. |
| Persistência PostgreSQL | `10.20.3.0/24` | 256 / 251 | Privada isolada | Armazenar os dados/recortes dos Microdados do ENEM. |

### 2.2. Mapeamento das tabelas de roteamento

| Tabela de rotas | Sub-rede | Destino | Próximo salto | Significado |
|---|---|---|---|---|
| Rota Pública | `10.20.1.0/24` | `10.20.0.0/16` / `0.0.0.0/0` | Local / Internet Gateway (IGW) | Comunicação interna na VPC + rota padrão aberta para a internet. |
| Rota Privada (App) | `10.20.2.0/24` | `10.20.0.0/16` / `0.0.0.0/0` | Local / NAT Gateway | Bloqueia entrada externa, mas permite saída para baixar pacotes/atualizações. |
| Rota Privada (DB) | `10.20.3.0/24` | `10.20.0.0/16` / `0.0.0.0/0` | Local / Sem rota (bloqueado) | Isolamento estrito: o banco só se comunica dentro da VPC. |

### 2.3. Correspondência laboratório Docker ↔ nuvem

| Laboratório Docker | Equivalente na nuvem | Função no Radar ENEM |
|---|---|---|
| `frontend-net` (172.20.10.0/24) | Sub-rede pública (rota p/ IGW) | Receber conexões no Reverse Proxy / Load Balancer. |
| `backend-net` (`internal: true`) | Sub-rede privada isolada (sem `0.0.0.0/0`) | Isolar o PostgreSQL de conexões externas diretas. |
| DNS interno (`127.0.0.11`) | Route 53 Private Hosted Zone / Azure Private DNS | Resolver nomes de serviços internos sem fixar IPs. |
| Container efêmero (Desafio 4) | Bastion Host / SSM Session Manager | Manutenção e auditoria seguras na sub-rede privada. |

### 2.4. Diagrama (a produzir)

Crie o diagrama visual da VPC `10.20.0.0/16` com as 3 sub-redes, seus CIDRs, o Internet Gateway,
o NAT Gateway e o sentido das setas de tráfego, e salve em `radar-enem-network/evidencias/04_diagrama_vpc.png`.
Esboço do fluxo:

```
Usuarios (HTTPS)
      |
      v
 [IGW] --> Sub-rede Publica 10.20.1.0/24 (Load Balancer + NAT GW)
                     |                         ^
                     v                         | (saida p/ internet via NAT)
          Sub-rede Privada App 10.20.2.0/24 (Backend) ---+
                     |
                     v
          Sub-rede Privada DB 10.20.3.0/24 (PostgreSQL)  [sem rota 0.0.0.0/0]
```

---

## 3. Questões discursivas (defesa arquitetural)

### 3.1. Isolamento em camadas

O `radar-proxy` **não** conseguiu pingar nem resolver `radar-db` porque os dois containers **não
compartilham nenhuma rede**: o proxy está só na `frontend-net` e o banco só na `backend-net`.
Como o DNS interno do Docker é escopado por rede, o nome `radar-db` sequer é resolvido a partir do
proxy; e, mesmo que o proxy tentasse o IP `172.20.20.50`, não há rota/interface ligando-o à
`backend-net`. Um invasor que comprometesse o Nginx público ficaria **contido na DMZ**: ele só
alcançaria o `radar-backend` (a face que o backend expõe na frontend-net). Para chegar ao banco,
seria preciso primeiro comprometer o próprio backend — a única ponte multi-homed — o que cria uma
**barreira extra** e **contém o movimento lateral**. A rede interna (`internal: true`), sem gateway
para fora, é o que garante que o PostgreSQL não seja acessível diretamente do host nem da DMZ.

### 3.2. Princípio da exposição mínima e papel do NAT

Colocar o PostgreSQL numa sub-rede **pública**, mesmo com senha forte, viola a **exposição mínima**
porque passa a existir um **caminho de rede alcançável de fora** (superfície de ataque exposta). A
senha vira a *única* linha de defesa, ficando sujeita a força bruta, exploração de CVEs do serviço,
varreduras e vazamentos de credenciais — defesa em profundidade deixa de existir. O correto é manter
o banco em sub-rede **privada isolada**, sem rota `0.0.0.0/0`: quem não tem caminho de rede sequer
tenta a autenticação.

O **NAT Gateway** entra quando o Backend (em sub-rede privada) precisa de **saída** para a internet —
por exemplo, baixar atualizações de pacotes ou arquivos/Microdados do INEP. O NAT permite conexões
**iniciadas de dentro para fora** (egress), traduzindo o IP privado para um IP público de saída e
mantendo o estado da conexão para o retorno — **sem** criar nenhuma rota de **entrada** não solicitada.
Assim o backend consegue atualizar-se e consumir dados externos, mas continua **inalcançável** por
conexões iniciadas da internet, preservando o isolamento.
