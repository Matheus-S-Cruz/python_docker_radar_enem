# Relatório Técnico — Aula 9

## Banco de Dados Relacional com PostgreSQL • Mini Radar ENEM

**Disciplina:** Computação em Nuvem
**Atividade:** Aula 9 — Banco relacional de demonstração e comprovação de persistência com volume Docker
**Projeto base:** Mini Radar ENEM
**Data de execução:** _preencher_

> As saídas de terminal/SQL abaixo estão com valores de **exemplo**. Substitua pelos resultados reais
> do seu ambiente e anexe os prints correspondentes da pasta [`evidencias/`](evidencias/).

---

## 1. Objetivo do experimento

Criar um banco de dados relacional de demonstração no **PostgreSQL 16**, modelar duas tabelas
relacionadas (`provas` e `questoes`), executar consultas SQL (incluindo `JOIN`) e, principalmente,
**comprovar a persistência dos dados** removendo e recriando o container sobre o mesmo **volume
Docker nomeado** (`radar-db-dados`). Ao final, explorar desafios de filtro, atualização, integridade
referencial, restrição `NOT NULL`, backup lógico, modelagem e segurança.

---

## 2. Comandos usados para criar o volume e iniciar o PostgreSQL

```bash
# Verificar o runtime
docker --version

# Criar o volume persistente nomeado
docker volume create radar-db-dados

# Iniciar o PostgreSQL apontando para o volume
docker run -d \
  --name radar-db \
  -e POSTGRES_USER=radar \
  -e POSTGRES_PASSWORD=radar_lab_123 \
  -e POSTGRES_DB=radar \
  -p 5432:5432 \
  -v radar-db-dados:/var/lib/postgresql/data \
  postgres:16

# Conferir estado
docker ps
docker logs radar-db
```

> Alternativa reproduzível: `docker compose up -d` usando o [`docker-compose.yml`](docker-compose.yml)
> deste diretório, que declara o mesmo serviço e o mesmo volume.

📸 Evidências: `01_docker_version.png`, `02_volume_criado.png`, `03_postgres_rodando.png`

---

## 3. Evidências das tabelas e consultas SQL

### Criação das tabelas (passo 5)

```sql
CREATE TABLE provas (...);
CREATE TABLE questoes (... prova_id INTEGER NOT NULL REFERENCES provas(id) ...);
```

Saída esperada: `CREATE TABLE` para cada comando. 📸 `04_criar_tabelas.png`

### Inserção de dados fictícios (passo 6)

Saída esperada: `INSERT 0 2` (provas) e `INSERT 0 3` (questoes). 📸 `05_inserir_dados.png`

### Consulta com JOIN (passo 7)

```sql
SELECT q.id, p.ano, q.assunto, q.dificuldade
FROM questoes AS q
JOIN provas AS p ON p.id = q.prova_id
ORDER BY p.ano DESC, q.assunto;
```

Resultado esperado (exemplo):

```text
 id | ano  |  assunto   | dificuldade
----+------+------------+-------------
  1 | 2025 | Ecologia   | média
  2 | 2025 | Matemática | alta
  3 | 2024 | Ecologia   | baixa
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

Resultado esperado: **as três questões continuam presentes**, provando que os dados sobreviveram à
remoção do container porque residem no volume nomeado `radar-db-dados`.

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

## 6. Resultados dos desafios adicionais (≥ 3)

### A — Filtro (Ecologia)

```sql
SELECT * FROM questoes WHERE assunto = 'Ecologia';
```
Retorna apenas as questões cujo `assunto = 'Ecologia'` (ids 1 e 3). 📸 `08_desafio_A_filtro.png`

### B — Atualização

```sql
UPDATE questoes SET dificuldade = 'baixa' WHERE id = 1;
SELECT * FROM questoes WHERE id = 1;
```
Saída: `UPDATE 1`; a linha passa a mostrar `dificuldade = baixa`. 📸 `09_desafio_B_update.png`

### C — Integridade referencial (erro esperado)

```sql
INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade)
VALUES (999, 'Teste', 'Registro inválido', 'baixa');
```
Erro esperado:
```text
ERROR:  insert or update on table "questoes" violates foreign key constraint ...
DETAIL:  Key (prova_id)=(999) is not present in table "provas".
```
**Explicação:** a FK impede vincular uma questão a uma prova inexistente — o banco **rejeita** a
escrita, preservando a consistência. 📸 `10_desafio_C_fk_erro.png`

### D — Restrição NOT NULL (erro esperado)

```sql
INSERT INTO questoes (prova_id, assunto, enunciado)
VALUES (1, NULL, 'Teste de campo obrigatório');
```
Erro esperado:
```text
ERROR:  null value in column "assunto" of relation "questoes" violates not-null constraint
```
**Explicação:** `assunto` é obrigatório; o banco não aceita `NULL`. 📸 `11_desafio_D_notnull_erro.png`

### E — Backup lógico (`pg_dump`)

```bash
docker exec radar-db pg_dump -U radar -d radar > backup-radar.sql
ls -lh backup-radar.sql
```
Gera um arquivo `.sql` no host com o esquema + dados — útil para restauração/migração.
📸 `12_desafio_E_backup.png`

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
  mas não contra exclusão/corrupção do próprio volume, erro humano ou falha de disco. O `pg_dump`
  (Desafio E) gera uma cópia lógica externa, que deve ser guardada **fora** do host (ex.: object
  storage com versionamento) e ter restauração testada periodicamente.
- **Segurança:** credenciais simples, porta exposta e senha em texto claro são aceitáveis só em
  laboratório. Produção exige secrets, menor privilégio, TLS, isolamento de rede e rotação de senha
  (ver Desafio G).

---

## 9. Conclusão técnica

O experimento demonstrou, na prática, os fundamentos de um banco relacional conteinerizado: modelagem
com PK/FK e restrições, consultas com `JOIN`, e — o ponto central — a **persistência via volume
Docker nomeado**, comprovada ao destruir e recriar o container sem perder os dados. Os desafios
reforçaram que o banco **ativamente protege a integridade** (rejeitando FK inválida e `NULL` em campo
obrigatório), que **backup é uma camada distinta** da persistência e que **segurança** depende de
práticas que vão muito além do que um laboratório usa. A proposta da tabela `assuntos` e as respostas
às perguntas abaixo indicam como o modelo evoluiria para um cenário real (usuários, desempenho por
assunto, múltiplos serviços).

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
