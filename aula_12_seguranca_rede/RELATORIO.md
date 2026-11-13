# Relatório Técnico — Aula 12

## Auditoria de Segurança de Rede e Exposição Controlada de Serviços — Radar ENEM

**Disciplina:** Aplicação de Serviços na Nuvem
**Atividade:** Aula 12 / EaD 4 — Firewalls, segurança de rede e exposição controlada de serviços
**Projeto base:** Radar ENEM
**Estudante(s) / Grupo:** _[preencher]_
**Data de entrega:** _[preencher]_

---

## Etapa 1 — Auditoria de vulnerabilidades e riscos

Parecer técnico sobre a tabela de regras atual (`R-01` a `R-05`). Para cada falha: vulnerabilidade
originada pela regra, impacto técnico/negócio e alocação correta (sub-rede pública × privada).

| Regra / item auditado | Vulnerabilidade e risco identificado | Impacto técnico e de negócio | Alocação correta (pública × privada) |
|---|---|---|---|
| **Falha 1 — R-01** (`All 0–65535` de `0.0.0.0/0`) | Regra "liberar tudo" anula o firewall: **toda** porta de **toda** camada fica acessível da internet. Viola frontalmente a exposição mínima e cria superfície de ataque máxima. | Qualquer serviço mal configurado (banco, cache, painel de debug) vira porta de entrada. Risco de invasão completa, sequestro de dados (ransomware) e indisponibilidade total do Radar ENEM. | Deve ser **removida**. Só o frontend fica em **sub-rede pública**; backend, banco e cache vão para **sub-redes privadas**. |
| **Falha 2 — R-02** (`TCP 22` de `0.0.0.0/0`) | SSH aberto para o mundo todo → exposto a **força bruta** automatizada e varreduras contínuas da internet. | Comprometimento de credenciais dá **acesso administrativo** à VM (execução remota, movimento lateral, exfiltração). Impacto de negócio: vazamento de microdados e perda de confiança. | SSH **restrito**: origem = IP fixo de gerência/VPN, idealmente via **Bastion Host / Session Manager** sem porta pública. Host de gerência na camada de aplicação/administração. |
| **Falha 3 — R-03** (`TCP 5432` de `0.0.0.0/0`) | PostgreSQL diretamente acessível da internet; a senha vira a **única** linha de defesa (sem defesa em profundidade). | Força bruta de credenciais, exploração de CVEs do Postgres, dump e **sequestro/vazamento dos microdados**. Impacto legal/LGPD e de reputação. | Banco em **sub-rede privada isolada**, sem rota `0.0.0.0/0`. Entrada `5432` só a partir do **SG da camada de aplicação**. |
| **Falha 4 — R-04 + SG único** (`TCP 6379` de `0.0.0.0/0` e um único SG para tudo) | Redis exposto e **sem autenticação por padrão** → leitura/escrita do cache por qualquer um. Além disso, um **SG único** amarra todas as camadas: impossível diferenciar o tráfego legítimo de cada uma. | Envenenamento de cache, vazamento de dados em memória, uso do Redis para execução de comandos/pivoting. O SG único impede a segmentação e amplia o raio de impacto (blast radius). | Cache em **sub-rede privada isolada**; `6379` só a partir do SG da aplicação. **Separar** em 3 SGs (`SG-Frontend`, `SG-Backend-API`, `SG-Dados`). |

---

## Etapa 2 — Proposta de refatoração: matriz de portas, protocolos e firewall

Substitui-se o SG único por **três grupos de segurança** distintos, liberando estritamente o
tráfego necessário (exposição mínima). Origens referenciam **outros SGs** (encadeamento) em vez de
blocos abertos.

| Grupo de segurança | Direção | Protocolo | Porta(s) | Origem / destino autorizado | Justificativa técnica (exposição mínima) |
|---|---|---|---|---|---|
| **SG-Frontend** | Entrada | TCP | 80, 443 | `0.0.0.0/0` | Única camada que **precisa** ser pública: é o ponto de acesso dos estudantes. HTTPS (443) obrigatório; 80 apenas para redirecionar ao 443. |
| **SG-Backend-API** | Entrada | TCP | 8080 | **SG-Frontend** (referência de SG) | A API só deve receber tráfego vindo do frontend, nunca da internet. Encadear SGs elimina a necessidade de expor 8080 publicamente. |
| **SG-Backend-API** | Entrada | TCP | 22 | IP de gerência/VPN **ou SG-Bastion** | Administração restrita a origem conhecida; sem SSH aberto ao mundo. Preferir Bastion Host / Session Manager. |
| **SG-Dados** | Entrada | TCP | 5432 | **SG-Backend-API** (referência de SG) | Só a aplicação consulta o banco. Nenhuma origem pública; nenhum acesso direto de scripts externos. |
| **SG-Dados** | Entrada | TCP | 6379 | **SG-Backend-API** (referência de SG) | Só a aplicação usa o cache. Redis nunca exposto ao host/internet; habilitar `requirepass` como camada extra. |
| **Regra adicional (saída)** | Saída | TCP | 443 | Destinos específicos (ex.: endpoints do INEP / repositórios de pacotes) via **NAT Gateway** | Backend e banco em sub-rede privada só precisam de **egress HTTPS** controlado para atualizações/ingestão de dados — não saída irrestrita (`R-05`). NAT permite saída iniciada de dentro sem abrir entrada. |

### Segmentação de rede alvo (liga Aula 11 → Aula 12)

| Camada | Sub-rede | Tipo | Security Group | Publica no host/internet? |
|---|---|---|---|---|
| Frontend (apresentação) | pública (rota p/ IGW) | Pública | `SG-Frontend` | Sim — 80/443 |
| Backend / API | privada (saída via NAT) | Privada | `SG-Backend-API` | Não — só recebe do SG-Frontend |
| PostgreSQL + Redis | privada isolada (sem `0.0.0.0/0`) | Privada isolada | `SG-Dados` | Não — só recebe do SG-Backend-API |

> O laboratório em `auditoria-rede/` reproduz exatamente essa separação: `docker-compose.inseguro.yml`
> (uma rede, tudo exposto) × `docker-compose.seguro.yml` (`frontend-net` pública + `backend-net`
> `internal: true`, com banco e cache **sem portas no host**).

---

## Etapa 3 — Checklist de segurança aplicado ao projeto integrador

Auditoria aplicada ao repositório/módulo do próprio grupo (Radar ENEM).

| Item de verificação | Status | Evidência técnica / plano de correção |
|---|---|---|
| **1. Isolamento de banco e dados internos** — o banco/arquivo de dados está protegido contra acesso público direto? | ✅ Conforme | No cenário seguro (`docker-compose.seguro.yml`), `db` e `cache` ficam na `backend-net` com `internal: true` e **sem `ports:`** — não há caminho de rede do host/internet. O backend os alcança pelo nome, dentro da rede interna. Evidência: `evidencias/04_isolamento_validado.png` (5432/6379 fechadas no host; backend→db/cache OK). |
| **2. Exposição de portas no contêiner / app** — quais portas estão expostas? Há portas de depuração abertas? | ✅ Conforme | No estado-alvo, **somente o proxy** publica porta (`8080`, que em produção vira 80/443). Banco (5432), cache (6379) e a API (8080 interno) **não** são publicados. O cenário inseguro é mantido apenas como prova do problema (`evidencias/01_cenario_inseguro.png` × `03_cenario_seguro.png`). Nenhuma porta de debug aberta. |
| **3. Proteção de credenciais e variáveis** — senhas/chaves/IPs fixos foram removidos do código e movidos para variáveis de ambiente? | ✅ Conforme | Senhas vêm de variáveis de ambiente (`.env`), e o `.env` está no `.gitignore` (versiona-se apenas o `.env.example` com placeholders). Nenhum segredo hardcoded no compose. Em produção: migrar para cofre gerenciado (AWS Secrets Manager / Azure Key Vault). |

---

## Questionário de verificação conceitual

### Questão 1 — regra de entrada do banco (`5432/TCP`) em arquitetura de 3 camadas

**Resposta correta: (B)** — Permitir tráfego em `5432/TCP` **exclusivamente** a partir do Security
Group da camada de aplicação (`SG-Backend-API`) ou da sub-rede privada do backend.

**Justificativa:** o banco não deve ter caminho de rede alcançável da internet. Encadear o SG do
banco ao SG da aplicação garante que só a camada autorizada conecte, aplicando exposição mínima e
defesa em profundidade. (A) mantém superfície pública mesmo com senha forte; (C) é um absurdo de
segurança; (D) remove a proteção em nome de latência.

### Questão 2 — Security Groups *stateful*

**Resposta correta: (A)** — Se uma requisição de entrada é permitida, o tráfego de **resposta**
daquela mesma conexão é automaticamente liberado na saída, sem precisar de regra explícita.

**Justificativa:** sendo *stateful*, o firewall rastreia o estado da conexão e libera o retorno
automaticamente — não é preciso abrir manualmente portas efêmeras altas. (B) inverte o padrão
(SGs são "deny por padrão"); (C) e (D) descrevem comportamentos que não correspondem a SGs
stateful.

### Questão 3 — SSH (`TCP 22`) aberto para `0.0.0.0/0`

**Resposta correta: (B)** — Risco de ataques automatizados de **força bruta via SSH** vindos de
qualquer IP; corrigir **restringindo a origem** ao IP fixo de gerência/VPN ou usando **Bastion
Host / gerenciador de sessão** sem porta pública exposta.

**Justificativa:** SSH aberto ao mundo é alvo constante de varreduras e brute force. A correção
alinhada à exposição mínima é reduzir a origem a uma faixa confiável ou eliminar a porta pública
via bastion. (A) confunde serviços; (C) troca de protocolo não resolve nada; (D) ignora que a
criptografia do SSH não impede tentativas de autenticação por força bruta.

---

## Conclusão

A configuração original falhava em todos os pilares de segurança de rede: um SG único com
`0.0.0.0/0` em todas as portas, SSH, PostgreSQL e Redis expostos à internet e saída irrestrita.
A refatoração aplica o **Princípio da Exposição Mínima** com **três Security Groups segregados**,
**isolamento em sub-redes pública/privada/privada-isolada** e **encadeamento de SGs** para que
cada camada receba apenas o tráfego estritamente necessário. O laboratório em `auditoria-rede/`
materializa e comprova, com evidências reais, a transição do cenário inseguro para o seguro.
