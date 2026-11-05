# Aula 11 — Redes e Containers com Docker (Mini Radar ENEM)

**Disciplina:** Computação em Nuvem
**Tema:** Isolamento de serviços e roteamento (hands-on)
**Projeto base:** Mini Radar ENEM

Laboratório prático de **redes Docker**: duas redes *custom bridge* para segmentar as camadas do
Radar ENEM, isolando o banco em sub-rede interna, usando o backend como **ponte multi-homed** e
expondo publicamente apenas o **Nginx reverse proxy**.

## Arquitetura alvo

```
                 Internet / Host
                        |
                   :8080 (unica porta publicada)
                        |
        +-------------- radar-proxy (172.20.10.10) --------------+
        |              frontend-net  172.20.10.0/24              |
        |                        |                               |
        |              radar-backend (172.20.10.20)              |  <- multi-homed
        +-------------------------------------------------------+
                                 |  (172.20.20.20)
        +------------- backend-net 172.20.20.0/24 (internal) ----+
        |                        |                               |
        |                  radar-db (172.20.20.50, PostgreSQL)   |  <- sem porta no host
        +-------------------------------------------------------+
```

- **frontend-net (`172.20.10.0/24`)** — DMZ pública: conecta o proxy (`.10`) à face frontal do backend (`.20`).
- **backend-net (`172.20.20.0/24`, `internal: true`)** — rede privada: conecta a face interna do backend (`.20`) ao banco (`.50`). O banco **não** participa da frontend-net e **não** expõe portas no host.

## Estrutura da pasta

```
aula_11_redes/
├── README.md                     <- este guia
├── RELATORIO.md                  <- relatorio tecnico + Incremento 4 (VPC) + questoes discursivas
└── radar-enem-network/           <- projeto do laboratorio (nome importa p/ o prefixo das redes)
    ├── docker-compose.yml        <- 3 servicos + 2 redes (inclui o radar-db que faltava no PDF)
    ├── nginx.conf                <- reverse proxy -> radar-backend
    ├── .gitignore
    ├── evidencias/               <- prints / .txt + diagrama da VPC (ver evidencias/README.md)
    │   ├── README.md
    │   ├── diagrama_vpc.svg      <- diagrama da VPC pronto (exportar p/ 04_diagrama_vpc.png)
    │   └── diagrama_vpc.mmd      <- fonte Mermaid do diagrama
    └── scripts/
        ├── 00_passo1_redes_manuais.sh   <- Passo 1 (cria/inspeciona/remove redes na mao)
        ├── 01_subir_ambiente.sh         <- docker compose up -d + espera o banco
        ├── 02_evidencia1_inspecao_rede.sh
        ├── 03_evidencia2_isolamento.sh
        ├── 04_evidencia3_desafios.sh    <- os 4 desafios investigativos
        ├── 05_capturar_evidencias.sh    <- salva todas as saidas em .txt
        ├── 06_gerar_diagrama_png.sh     <- converte o diagrama SVG -> PNG
        └── 99_limpar.sh                 <- docker compose down -v
```

> O repositório também traz um `.devcontainer/` na **raiz** (Docker-in-Docker) para rodar o
> laboratório direto no GitHub Codespaces sem configuração manual.

> **Nota:** o `docker-compose.yml` do PDF não mostrava o serviço do banco, mas os desafios usam
> `radar-db` em `172.20.20.50`. Por isso o serviço `db-postgres` (container `radar-db`,
> `postgres:15-alpine`, user `radar_admin`, db `radarenem`, senha `enem_secret_2026`) foi incluído.

---

## Como rodar no GitHub Codespaces

> O repositório inclui um `.devcontainer/` na raiz que provisiona **Docker-in-Docker** e já
> ajusta as permissões dos scripts automaticamente (via `postCreateCommand`). Ao criar o
> Codespace, aguarde a mensagem "Ambiente pronto!" no terminal de setup.

### 1. Abrir o Codespace e entrar na pasta

No repositório do GitHub: **Code → Codespaces → Create codespace on `aula-11-redes-containers`**
(ou na branch já mesclada). O devcontainer sobe automaticamente. No terminal do Codespace:

```bash
cd aula_11_redes/radar-enem-network
# As permissoes ja foram ajustadas pelo devcontainer; se precisar: chmod +x scripts/*.sh
```

### 2. (Opcional, mas recomendado) Passo 1 — redes manuais

Demonstra o IPAM criando/inspecionando/removendo as redes na mão, antes do Compose:

```bash
bash scripts/00_passo1_redes_manuais.sh
```

### 3. Passo 2/5 — subir o ambiente

```bash
bash scripts/01_subir_ambiente.sh
```

Isso roda `docker compose up -d`, espera o PostgreSQL ficar pronto e mostra `docker compose ps`.

### 4. Rodar os testes e desafios

```bash
bash scripts/02_evidencia1_inspecao_rede.sh    # Evidencia 1
bash scripts/03_evidencia2_isolamento.sh       # Evidencia 2
bash scripts/04_evidencia3_desafios.sh         # Evidencia 3 (os 4 desafios)
```

### 5. Limpar ao terminar

```bash
bash scripts/99_limpar.sh
```

---

## Como salvar as evidências (entregáveis do AVA)

Você precisa de **3 capturas de tela** + **1 diagrama** + **relatório** (ver `RELATORIO.md`).
Recomendo tirar os prints enquanto roda cada script no terminal do Codespace.

### Captura 1 — Inspeção de rede
Rode e tire print da saída (CIDR `172.20.20.0/24`, `"Internal": true`, IPs de `radar-backend` e `radar-db`):
```bash
bash scripts/02_evidencia1_inspecao_rede.sh
```
Salve como `evidencias/01_inspecao_backend_net.png`.

### Captura 2 — Testes de isolamento (Passo 5)
Print mostrando proxy OK, falha `radar-proxy → radar-db` e sucesso `radar-backend → radar-db`:
```bash
bash scripts/03_evidencia2_isolamento.sh
```
Salve como `evidencias/02_isolamento.png`.

### Captura 3 — Os 4 desafios (Passo 6)
Print do `nslookup`, `ip route show`, desconexão (502) e acesso via Bastion Host:
```bash
bash scripts/04_evidencia3_desafios.sh
```
Salve como `evidencias/03_desafios.png`.

### Diagrama (Incremento 4) — já incluído
O diagrama da VPC `10.20.0.0/16` já está pronto em `evidencias/diagrama_vpc.svg` (e `.mmd` Mermaid).
Para gerar o PNG para o PDF:
```bash
bash scripts/06_gerar_diagrama_png.sh      # cria evidencias/04_diagrama_vpc.png
```
Se preferir, abra o `.svg` no navegador e salve como PNG, ou edite o `.mmd` em
[mermaid.live](https://mermaid.live) e exporte por lá.

### Alternativa: salvar as saídas em texto
Para gerar `.txt` de todas as evidências de uma vez (útil para anexar junto dos prints):
```bash
bash scripts/05_capturar_evidencias.sh
```

### Montar o PDF final
Junte, nesta ordem, em um único PDF para enviar no AVA:
1. Captura 1 (inspeção de rede)
2. Captura 2 (isolamento)
3. Captura 3 (4 desafios)
4. Diagrama da VPC
5. Relatório técnico (conteúdo de `RELATORIO.md`)

---

## Dicas de captura no Codespaces

- O terminal do Codespace roda no navegador: use a tecla de **print do seu SO** (Windows: `Win+Shift+S`; macOS: `Cmd+Shift+4`) para recortar só a área do terminal.
- Para saídas longas (ex.: `network inspect`), prefira o print do **resumo** que os scripts imprimem no final, ou anexe o `.txt` gerado pelo script `05_`.
- A porta `8080` abre automaticamente na aba **Ports** do Codespace — dá para testar o proxy pelo navegador também.
