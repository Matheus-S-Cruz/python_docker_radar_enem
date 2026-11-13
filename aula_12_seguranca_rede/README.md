# Aula 12 — Auditoria de Segurança de Rede e Exposição Controlada de Serviços

**Disciplina:** Aplicação de Serviços na Nuvem
**Tema:** Firewalls, segurança de rede e exposição controlada de serviços (EaD 4 — Auditoria de redes e segurança)
**Projeto base:** Radar ENEM
**Carga horária:** 3h00 (Modalidade EaD / AVA)
**Estratégia:** Sala de Aula Invertida / Ensaio Tecnológico

---

## 1. Contexto (PBL)

O ambiente de homologação do **Radar ENEM** foi configurado às pressas para liberar testes
funcionais rápidos e, no processo, as boas práticas de proteção de rede foram negligenciadas.
Toda a arquitetura de três camadas foi colocada na **mesma rede virtual** e amarrada a um
**único Grupo de Segurança (Security Group / Firewall de Nuvem)** com regras permissivas.

As três camadas são:

1. **Apresentação (Frontend Web)** — acessada pelos estudantes no navegador em `80/TCP` e `443/TCP`.
2. **Aplicação (Motor Estatístico / API Backend)** — contêiner que recebe filtros dinâmicos
   (nota, faixa de renda) e processa os cruzamentos em `8080/TCP`.
3. **Dados (Banco + Cache)** — PostgreSQL em `5432/TCP` com os microdados tratados e um cache
   Redis em memória em `6379/TCP`.

### Tabela de regras atual (a ser auditada)

| ID | Direção | Protocolo | Porta / Faixa | Origem / Destino | Ação | Descrição atual |
|----|---------|-----------|---------------|------------------|------|-----------------|
| R-01 | Entrada | Todos (All) | 0 – 65535 | `0.0.0.0/0` | Permitir | "Liberar tudo para evitar erros de conexão no deploy" |
| R-02 | Entrada | TCP | 22 | `0.0.0.0/0` | Permitir | Acesso SSH remoto para os desenvolvedores |
| R-03 | Entrada | TCP | 5432 | `0.0.0.0/0` | Permitir | Acesso direto ao banco pelos scripts locais de ETL |
| R-04 | Entrada | TCP | 6379 | `0.0.0.0/0` | Permitir | Acesso ao serviço de cache em memória |
| R-05 | Saída | Todos (All) | 0 – 65535 | `0.0.0.0/0` | Permitir | Saída padrão irrestrita para qualquer destino |

### Objetivo do desafio

Realizar a **Auditoria de Segurança de Rede** desta arquitetura e propor a refatoração das regras
de firewall aplicando:

- o **Princípio da Exposição Mínima**;
- o **isolamento em sub-redes públicas e privadas** (ligando os conceitos da Aula 11 com a Aula 12);
- a **segregação de Grupos de Segurança** (um SG por camada).

---

## 2. Estrutura da pasta

```
aula_12_seguranca_rede/
├── README.md                     <- este guia + roteiro de evidências
├── RELATORIO.md                  <- entregável: auditoria, matriz de SGs, checklist e questionário
└── auditoria-rede/               <- laboratório prático (reproduz o cenário inseguro -> seguro)
    ├── docker-compose.inseguro.yml   <- 1 rede única + tudo exposto (espelha R-01..R-05)
    ├── docker-compose.seguro.yml     <- 2 redes + banco/cache isolados (estado-alvo)
    ├── .env.example                  <- variáveis de ambiente (segredos fora do código)
    ├── .gitignore
    ├── evidencias/                   <- salve aqui os prints / .txt (ver evidencias/README.md)
    └── scripts/
        ├── 01_subir_inseguro.sh      <- sobe o cenário vulnerável
        ├── 02_auditar_portas.sh      <- varre as portas expostas (nmap/nc) = foto do problema
        ├── 03_subir_seguro.sh        <- sobe o cenário refatorado (exposição mínima)
        ├── 04_validar_isolamento.sh  <- prova que 5432/6379 não respondem mais do host
        ├── 05_capturar_evidencias.sh <- salva todas as saídas em .txt
        └── 99_limpar.sh              <- docker compose down -v dos dois cenários
```

---

## 3. Entregáveis exigidos pelo AVA

Tudo está consolidado no **`RELATORIO.md`**:

1. **Etapa 1 — Auditoria de vulnerabilidades** (4 falhas críticas: R-01, R-02, R-03, R-04/SG único).
2. **Etapa 2 — Matriz de refatoração** com 3 Grupos de Segurança (`SG-Frontend`, `SG-Backend-API`, `SG-Dados`).
3. **Etapa 3 — Checklist aplicado ao repositório** do próprio grupo (isolamento, portas expostas, segredos).
4. **Questionário conceitual** (3 questões, com justificativa).

As **evidências práticas** (prints/`.txt`) comprovam o checklist e a diferença entre o cenário
inseguro e o seguro. O **roteiro para capturá-las** está na seção 5 deste README e em
`auditoria-rede/evidencias/README.md`.

---

## 4. Como rodar o laboratório (GitHub Codespaces)

> O Codespaces já vem com Docker e Docker Compose. O `nmap`/`nc` são instalados pelo script `02`
> caso ainda não existam.

### 4.1. Entrar na pasta e dar permissão aos scripts

```bash
cd aula_12_seguranca_rede/auditoria-rede
cp .env.example .env            # cria o .env local (NÃO versionado)
chmod +x scripts/*.sh
```

### 4.2. Subir o cenário INSEGURO (o problema)

```bash
bash scripts/01_subir_inseguro.sh
```

### 4.3. Auditar as portas expostas (a foto do risco)

```bash
bash scripts/02_auditar_portas.sh
```

Deve mostrar `5432` (PostgreSQL) e `6379` (Redis) **abertas no host** — exatamente a exposição
indevida descrita nas regras R-03 e R-04.

### 4.4. Subir o cenário SEGURO (estado-alvo) e validar o isolamento

```bash
bash scripts/03_subir_seguro.sh
bash scripts/04_validar_isolamento.sh
```

Agora apenas a face pública responde; `5432`/`6379` deixam de responder a partir do host.

### 4.5. Limpar ao terminar

```bash
bash scripts/99_limpar.sh
```

---

## 5. Roteiro para tirar as evidências

Você precisa de **4 capturas** + o **relatório** (`RELATORIO.md`). Tire os prints no terminal do
Codespaces enquanto roda cada script. Para gerar também os `.txt`, rode `scripts/05_capturar_evidencias.sh`.

| # | Captura | Comando | Salvar como |
|---|---------|---------|-------------|
| 1 | **Cenário inseguro no ar** — `docker compose ps` do stack vulnerável com todas as portas mapeadas no host. | `bash scripts/01_subir_inseguro.sh` | `evidencias/01_cenario_inseguro.png` |
| 2 | **Auditoria de portas (risco)** — varredura mostrando `5432` e `6379` **abertas** para fora. | `bash scripts/02_auditar_portas.sh` | `evidencias/02_portas_expostas.png` |
| 3 | **Cenário seguro no ar** — `docker compose ps` do stack refatorado: só a camada pública publica porta. | `bash scripts/03_subir_seguro.sh` | `evidencias/03_cenario_seguro.png` |
| 4 | **Validação de isolamento** — prova de que `5432`/`6379` **não respondem** do host e que o backend ainda alcança o banco pela rede interna. | `bash scripts/04_validar_isolamento.sh` | `evidencias/04_isolamento_validado.png` |

> **Diagrama (opcional, recomendado):** desenhe a VPC alvo com as 3 sub-redes (pública para o
> frontend, privada para o backend, privada isolada para dados+cache), os 3 Security Groups e o
> sentido do tráfego autorizado. Ferramentas: [draw.io](https://app.diagrams.net), Excalidraw ou
> PowerPoint. Salve como `evidencias/05_diagrama_segmentacao.png`.

### Montar o PDF final para o AVA

Junte, nesta ordem, em um único PDF:

1. Captura 1 (cenário inseguro)
2. Captura 2 (portas expostas — auditoria)
3. Captura 3 (cenário seguro)
4. Captura 4 (isolamento validado)
5. (Opcional) Diagrama da segmentação
6. Relatório técnico (conteúdo de `RELATORIO.md`)

---

## 6. Dicas de captura no Codespaces

- O terminal roda no navegador: use o print do seu SO (Windows: `Win+Shift+S`; macOS: `Cmd+Shift+4`)
  para recortar só a área do terminal.
- Para saídas longas, prefira o **resumo** que cada script imprime no final, ou anexe o `.txt`
  gerado por `scripts/05_capturar_evidencias.sh`.
- Nunca faça commit do arquivo `.env` com as senhas — ele já está no `.gitignore`.
