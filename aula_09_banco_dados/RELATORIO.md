# Relatório Técnico — Aula 9

## Banco de Dados Relacional com PostgreSQL • Mini Radar ENEM

**Disciplina:** Computação em Nuvem
**Atividade:** Aula 9 — Banco relacional de demonstração e comprovação de persistência com volume Docker
**Projeto base:** Mini Radar ENEM
**Data de execução:** 11/11/2026

### Ambiente de execução

| Item | Valor |
|---|---|
| Runtime de containers | **Docker 29.9.2** (`build a82e5289`) |
| Imagem do banco | `postgres:16` → **PostgreSQL 16.15 (Debian 16.15-1.pgdg13+2)** |
| Volume nomeado | `radar-db-dados` (driver `local`) |
| Porta publicada | `5432:5432` |

> As saídas de terminal/SQL reproduzidas abaixo são as **capturas reais** da execução. Os prints
> correspondentes estão na pasta [`evidencias/`](evidencias/).

---

## 1. Objetivo do experimento

Criar um banco de dados relacional de demonstração no **PostgreSQL 16**, modelar duas tabelas
relacionadas (`provas` e `questoes`), executar consultas SQL (incluindo `JOIN`) e, principalmente,
**comprovar a persistência dos dados** removendo e recriando o container sobre o mesmo **volume
Docker nomeado** (`radar-db-dados`). Ao final, explorar desafios de filtro, atualização e integridade
referencial (foram executados os desafios **A, B e C**, atendendo o mínimo de três).

---

## 2. Comandos usados para criar o volume e iniciar o PostgreSQL

```bash
# Verificar o runtime
$ docker --version
Docker version 29.9.2-2, build a82e528901260c8df6073311379eac65f92db204

# Criar o volume persistente nomeado
$ docker volume create radar-db-dados
radar-db-dados

$ docker volume ls
DRIVER    VOLUME NAME
local     radar-db-dados

# Iniciar o PostgreSQL apontando para o volume
$ docker run -d \
  --name radar-db \
  -e POSTGRES_USER=radar \
  -e POSTGRES_PASSWORD=radar_lab_123 \
  -e POSTGRES_DB=radar \
  -p 5432:5432 \
  -v radar-db-dados:/var/lib/postgresql/data \
  postgres:16
# (imagem postgres:16 baixada do registry)
f537d6010354e5a9c8950c20f1d70a2eb9e35e7c9c71633298d4be72ede254b0

# Conferir estado
$ docker ps
CONTAINER ID   IMAGE         COMMAND                  STATUS         PORTS                      NAMES
f537d6010354   postgres:16   "docker-entrypoint.s…"   Up 6 seconds   0.0.0.0:5432->5432/tcp …   radar-db
```

Os logs (`docker logs radar-db`) confirmaram a inicialização:
`database system is ready to accept connections` — PostgreSQL 16.15.

> Alternativa reproduzível: `docker compose up -d` usando o [`docker-compose.yml`](docker-compose.yml)
> deste diretório, que declara o mesmo serviço e o mesmo volume.

📸 Evidências: `01_docker_version.png`, `02_volume_criado.png`, `03_postgres_rodando_01.png`,
`03_postgres_rodando_2.png`

---

## 3. Evidências das tabelas e consultas SQL

### Criação das tabelas (passo 5)

```sql
CREATE TABLE provas (...);        --> CREATE TABLE
CREATE TABLE questoes (... prova_id INTEGER NOT NULL REFERENCES provas(id) ...);  --> CREATE TABLE
```

Ambos os comandos retornaram `CREATE TABLE`. 📸 `04_criar_tabelas.png`

### Inserção de dados fictícios (passo 6)

Saídas reais: `INSERT 0 2` (provas) e `INSERT 0 3` (questoes). 📸 `05_inserir_dados.png`

### Conferência das tabelas e consulta com JOIN (passo 7)

```text
radar=# SELECT * FROM provas;
 id | ano  |     nome
----+------+--------------
  1 | 2025 | ENEM regular
  2 | 2024 | ENEM regular
(2 rows)

radar=# SELECT * FROM questoes;
 id | prova_id |  assunto   |                    enunciado                    | dificuldade
----+----------+------------+-------------------------------------------------+-------------
  1 |        1 | Ecologia   | Questão demonstrativa sobre ecossistemas        | média
  2 |        1 | Matemática | Questão demonstrativa sobre funções             | alta
  3 |        2 | Ecologia   | Questão demonstrativa sobre cadeias alimentares | baixa
(3 rows)
```

Consulta com **JOIN**:

```sql
SELECT q.id, p.ano, q.assunto, q.dificuldade
FROM questoes AS q
JOIN provas AS p ON p.id = q.prova_id
ORDER BY p.ano DESC, q.assunto;
```

Resultado real:

```text
 id | ano  |  assunto   | dificuldade
----+------+------------+-------------
  1 | 2025 | Ecologia   | média
  2 | 2025 | Matemática | alta
  3 | 2024 | Ecologia   | baixa
(3 rows)
```

📸 `06_consulta_join.png`

**Papel de `prova_id`:** é a **chave estrangeira (FK)** de `questoes` que referencia a **chave
primária (PK)** `id` de `provas`. Ela garante que toda questão esteja vinculada a uma prova
existente (integridade referencial) e é a coluna usada pelo `JOIN` para relacionar as tabelas.

---

## 4. Evidência da consulta após recriar o container

```bash
docker rm -f radar-db
docker run -d --name radar-db -e POSTGRES_USER=radar -e POSTGRES_PASSWORD=radar_lab_123 \
  -e POSTGRES_DB=radar -p 5432:5432 -v radar-db-dados:/var/lib/postgresql/data postgres:16

docker exec -it radar-db psql -U radar -d radar \
  -c "SELECT q.id, p.ano, q.assunto FROM questoes AS q JOIN provas AS p ON p.id = q.prova_id;"
```

Resultado real após recriar o container:

```text
 id | ano  |  assunto
----+------+------------
  1 | 2025 | Ecologia
  2 | 2025 | Matemática
  3 | 2024 | Ecologia
(3 rows)
```

**As três questões continuam presentes**, provando que os dados sobreviveram à remoção do container
porque residem no volume nomeado `radar-db-dados`. (Esta consulta foi feita **antes** do desafio B,
por isso a questão 1 ainda aparece com os dados originais.)

📸 `07_persistencia_apos_recriar.png`

---

## 5. Modelo de dados (tabelas, PK e FK)

```text
┌─────────────────────────┐          ┌──────────────────────────────────┐
│          provas         │          │             questoes             │
├─────────────────────────┤          ├──────────────────────────────────┤
│ id   SERIAL  PK          │◄────┐    │ id          SERIAL  PK            │
│ ano  INTEGER NOT NULL    │     │    │ prova_id    INTEGER NOT NULL  FK ─┼──┐
│ nome TEXT    NOT NULL    │     └────┤ assunto     TEXT    NOT NULL      │  │
└─────────────────────────┘          │ enunciado   TEXT    NOT NULL      │  │
                                      │ dificuldade TEXT (CHECK: baixa/   │  │
                                      │             média/alta)           │  │
                                      └──────────────────────────────────┘  │
          provas.id  (1) ───────────────────────── (N)  questoes.prova_id ──┘
                       relação um-para-muitos (1:N)
```

- **PK (chave primária):** `provas.id` e `questoes.id` — identificam cada registro de forma única.
- **FK (chave estrangeira):** `questoes.prova_id` → `provas.id` — garante integridade referencial.
- **Restrições:** `NOT NULL` em campos obrigatórios e `CHECK` limitando `dificuldade` a
  `baixa | média | alta`.
- **Cardinalidade:** uma prova pode ter várias questões; cada questão pertence a exatamente uma prova.

---

## 6. Resultados dos desafios adicionais

Foram executados **três desafios (A, B e C)**, atendendo ao mínimo exigido pelo roteiro.

### A — Filtro (Ecologia) ✅ executado

```sql
SELECT * FROM questoes WHERE assunto = 'Ecologia';
```
Resultado real (apenas as questões de Ecologia — ids 1 e 3):

```text
 id | prova_id | assunto  |                    enunciado                    | dificuldade
----+----------+----------+-------------------------------------------------+-------------
  1 |        1 | Ecologia | Questão demonstrativa sobre ecossistemas        | média
  3 |        2 | Ecologia | Questão demonstrativa sobre cadeias alimentares | baixa
(2 rows)
```
📸 `08_desafio_A_filtro.png`

### B — Atualização ✅ executado

```sql
UPDATE questoes SET dificuldade = 'baixa' WHERE id = 1;
SELECT * FROM questoes WHERE id = 1;
```
Resultado real — `UPDATE 1` e a questão 1 passou de `média` para `baixa`:

```text
UPDATE 1
 id | prova_id | assunto  |                enunciado                 | dificuldade
----+----------+----------+------------------------------------------+-------------
  1 |        1 | Ecologia | Questão demonstrativa sobre ecossistemas | baixa
(1 row)
```
📸 `09_desafio_B_update.png`

### C — Integridade referencial ✅ executado (erro esperado)

```sql
INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade)
VALUES (999, 'Teste', 'Registro inválido', 'baixa');
```
Erro real retornado pelo PostgreSQL:
```text
ERROR:  insert or update on table "questoes" violates foreign key constraint "questoes_prova_id_fkey"
DETAIL:  Key (prova_id)=(999) is not present in table "provas".
```
**Explicação:** a FK `questoes_prova_id_fkey` impede vincular uma questão a uma prova inexistente — o
banco **rejeita** a escrita, preservando a consistência (integridade referencial). 📸 `10_desafio_C_fk_erro.png`

### D — Restrição NOT NULL ⬜ não executado (opcional)

Desafio não realizado nesta entrega (o mínimo de três já foi atendido por A, B e C). Caso queira
incluí-lo, o comando abaixo deve retornar erro de *not-null constraint* em `assunto`:

```sql
INSERT INTO questoes (prova_id, assunto, enunciado)
VALUES (1, NULL, 'Teste de campo obrigatório');
-- ERROR: null value in column "assunto" of relation "questoes" violates not-null constraint
```

### E — Backup lógico (`pg_dump`) ⬜ não executado (opcional)

Desafio não realizado nesta entrega. Para incluí-lo:

```bash
docker exec radar-db pg_dump -U radar -d radar > backup-radar.sql
ls -lh backup-radar.sql
```
Gera um arquivo `.sql` no host com o esquema + dados — útil para restauração/migração.

### F — Modelagem: tabela `assuntos` (proposta)

Hoje `assunto` é texto livre repetido em cada questão. Normalizando:

```sql
CREATE TABLE assuntos (
  id   SERIAL PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE
);
ALTER TABLE questoes ADD COLUMN assunto_id INTEGER REFERENCES assuntos(id);
```

**Relação:** `assuntos (1) → (N) questoes` via FK `questoes.assunto_id → assuntos.id`. Vantagens:
evita digitação inconsistente ("Ecologia" vs "ecologia"), centraliza o catálogo de assuntos,
facilita agregações (ex.: desempenho por assunto) e economiza espaço.

### G — Segurança: senha simples

A senha `radar_lab_123` é previsível, está em texto claro no comando/compose e a porta `5432` é
exposta no host. Em produção isso permitiria acesso não autorizado, vazamento e ataques de força
bruta. **Boas práticas:** senhas fortes e aleatórias, armazenadas em *secrets*/variáveis de ambiente
(nunca no código), princípio do menor privilégio por usuário do banco, TLS, não expor a porta
publicamente (rede interna/VPC) e rotação periódica de credenciais.

---

## 7. Diagrama: aplicação → banco → volume persistente

```text
┌────────────────────────┐      conexão      ┌─────────────────────────┐
│  Aplicação Radar ENEM   │  TCP 5432 (SQL)  │   PostgreSQL 16          │
│  (Flask / cliente psql) │ ───────────────▶ │   container "radar-db"   │
└────────────────────────┘                   │   (efêmero/descartável)  │
                                              └────────────┬────────────┘
                                                           │ grava/lê os arquivos do banco em
                                                           │ /var/lib/postgresql/data
                                                           ▼
                                              ┌─────────────────────────┐
                                              │  Docker Volume NOMEADO   │
                                              │  "radar-db-dados"        │
                                              │  (ciclo de vida próprio, │
                                              │   sobrevive ao container)│
                                              └─────────────────────────┘
```

O container pode ser removido e recriado; o **volume** mantém os dados, que são religados ao novo
container no mesmo caminho `/var/lib/postgresql/data`.

---

## 8. Análise sobre persistência, backup e segurança

- **Persistência:** ao separar o armazenamento (volume) do processo (container), os dados têm ciclo
  de vida independente. Recriar `radar-db` sobre `radar-db-dados` mantém provas e questões — foi o
  que a consulta do item 4 comprovou.
- **Backup:** persistência **não** é backup. O volume protege contra a destruição do *container*,
  mas não contra exclusão/corrupção do próprio volume, erro humano ou falha de disco. Uma cópia
  lógica (ex.: `pg_dump`, descrito no Desafio E) deve ser guardada **fora** do host (ex.: object
  storage com versionamento) e ter a restauração testada periodicamente.
- **Segurança:** credenciais simples, porta exposta e senha em texto claro são aceitáveis só em
  laboratório. Produção exige secrets, menor privilégio, TLS, isolamento de rede e rotação de senha
  (ver Desafio G).

---

## 9. Conclusão técnica

O experimento demonstrou, na prática, os fundamentos de um banco relacional conteinerizado: modelagem
com PK/FK e restrições, consultas com `JOIN`, e — o ponto central — a **persistência via volume
Docker nomeado**, comprovada ao destruir e recriar o container (Docker 29.9.2 / PostgreSQL 16.15) sem
perder os dados. Os desafios executados (A — filtro, B — atualização, C — integridade referencial)
reforçaram que o banco **ativamente protege a integridade**, rejeitando a inserção de uma questão com
`prova_id` inexistente (erro de *foreign key constraint*). A análise registrou ainda que **backup é
uma camada distinta** da persistência e que **segurança** depende de práticas que vão muito além do
que um laboratório usa. A proposta da tabela `assuntos` e as respostas às perguntas abaixo indicam
como o modelo evoluiria para um cenário real (usuários, desempenho por assunto, múltiplos serviços).

---

## 10. Perguntas para responder

**1. Qual a diferença entre um arquivo CSV e um banco relacional neste cenário?**
Um CSV é um arquivo plano, sem tipos fortes, sem relacionamentos, sem controle de concorrência nem
integridade — qualquer leitura/escrita é manual e sujeita a inconsistências. O banco relacional
oferece esquema tipado, chaves (PK/FK), restrições (`NOT NULL`, `CHECK`), transações, consultas
`SQL`/`JOIN` e acesso concorrente controlado. Aqui, o relacionamento provas↔questões e a validação
da FK/`NOT NULL` seriam impossíveis de garantir num CSV.

**2. O que são tabela, registro, coluna, PK e FK?**
- **Tabela:** estrutura que armazena dados de uma entidade (ex.: `provas`).
- **Registro (linha):** uma ocorrência da entidade (uma prova específica).
- **Coluna (campo):** um atributo com tipo (ex.: `ano INTEGER`).
- **PK (chave primária):** coluna(s) que identificam unicamente cada registro (`provas.id`).
- **FK (chave estrangeira):** coluna que referencia a PK de outra tabela, criando o relacionamento
  (`questoes.prova_id → provas.id`).

**3. O que o JOIN fez na consulta?**
Combinou linhas de `questoes` com linhas de `provas` casando `questoes.prova_id = provas.id`,
permitindo exibir atributos das duas tabelas juntos (ex.: o `ano` da prova ao lado do `assunto` da
questão).

**4. Por que os dados sobreviveram à remoção do container?**
Porque estavam gravados em `/var/lib/postgresql/data`, que é um **volume nomeado** (`radar-db-dados`)
— um recurso externo ao container, com ciclo de vida próprio. Remover o container apaga apenas sua
camada efêmera, não o volume.

**5. O que aconteceria se o volume fosse removido?**
Os arquivos do banco seriam **perdidos definitivamente**: todas as provas e questões desapareceriam,
pois é no volume que o PostgreSQL mantém seus dados. Por isso o roteiro proíbe
`docker volume rm radar-db-dados` antes de concluir.

**6. Persistência é o mesmo que backup? Justifique.**
Não. Persistência garante que o dado **sobreviva ao ciclo de vida do container**, mas ele continua
num único lugar (o volume). Backup é uma **cópia independente** feita para recuperar o dado após
perda/corrupção/erro — como o `pg_dump` guardado externamente. Um volume persistente ainda pode ser
apagado ou corrompido; sem backup, não há recuperação.

**7. Que riscos existem ao usar credenciais simples e expor a porta do banco?**
Senha fraca/previsível facilita força bruta; credencial em texto claro vaza facilmente; a porta
`5432` exposta permite conexões de qualquer origem que alcance o host. Juntos, abrem caminho para
acesso não autorizado, roubo/alteração de dados e indisponibilidade. Mitigações: secrets, menor
privilégio, TLS, firewall/rede interna e não publicar a porta.

**8. Como o modelo poderia crescer para registrar usuários e desempenho por assunto?**
Adicionando entidades e relacionamentos, por exemplo:
```text
usuarios(id PK, nome, email UNIQUE)
assuntos(id PK, nome UNIQUE)
respostas(id PK, usuario_id FK->usuarios, questao_id FK->questoes, correta BOOLEAN, respondido_em TIMESTAMP)
```
Com `questoes` ligada a `assuntos` (FK `assunto_id`), seria possível agregar o desempenho por
assunto com `JOIN` + `GROUP BY` (ex.: % de acertos de cada usuário por assunto), evoluindo o Mini
Radar ENEM de demonstração para algo analítico.
