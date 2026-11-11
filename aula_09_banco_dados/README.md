# Aula 9 — Banco de Dados Relacional com PostgreSQL

## Mini Radar ENEM • Computação em Nuvem

**Objetivo:** criar um banco relacional de demonstração, executar consultas SQL e **comprovar a
persistência** usando um volume Docker nomeado.

> ⚠️ **Importante:** use **somente dados fictícios**. As credenciais abaixo servem **apenas** para
> laboratório — **nunca** reutilize essa senha em produção.
>
> 🚫 **Não execute** `docker volume rm radar-db-dados` antes de concluir a atividade. Isso apagaria
> o volume que guarda os dados.

---

## Estrutura da pasta

```text
aula_09_banco_dados/
├── README.md               # este guia passo a passo (todos os comandos)
├── docker-compose.yml      # alternativa reproduzível ao "docker run"
├── RELATORIO.md            # modelo do relatório técnico (preencher com evidências)
├── sql/
│   ├── 01_criar_tabelas.sql    # passo 5  — CREATE TABLE provas / questoes
│   ├── 02_inserir_dados.sql    # passo 6  — INSERT de dados fictícios
│   ├── 03_consultas.sql        # passo 7  — SELECT e JOIN
│   ├── 04_persistencia.sql     # passo 8  — consulta após recriar o container
│   └── 05_desafios.sql         # passo 9  — desafios adicionais (A–E)
└── evidencias/
    └── README.md           # quais prints colocar após cada comando
```

---

## 1. Pré-requisitos

Abra um terminal Bash e verifique se o Docker está disponível:

```bash
docker --version
```

📸 **Evidência:** `01_docker_version.png`

---

## 2. Criar um volume persistente

```bash
docker volume create radar-db-dados
```

Confira que o volume existe:

```bash
docker volume ls
```

📸 **Evidência:** `02_volume_criado.png`

---

## 3. Iniciar o PostgreSQL

> As credenciais são **exclusivamente** para laboratório. Não reutilize essa senha em produção.

```bash
docker run -d \
  --name radar-db \
  -e POSTGRES_USER=radar \
  -e POSTGRES_PASSWORD=radar_lab_123 \
  -e POSTGRES_DB=radar \
  -p 5432:5432 \
  -v radar-db-dados:/var/lib/postgresql/data \
  postgres:16
```

Verifique se o container está em execução:

```bash
docker ps
```

Se o container não aparecer como ativo, consulte os logs:

```bash
docker logs radar-db
```

📸 **Evidência:** `03_postgres_rodando.png` (saída de `docker ps`)

> 💡 **Alternativa com Docker Compose** (equivalente aos passos 2 e 3):
> ```bash
> docker compose up -d
> docker compose ps
> ```
> Veja o arquivo [`docker-compose.yml`](docker-compose.yml). Ele cria o mesmo volume nomeado e o
> mesmo serviço PostgreSQL de forma declarativa e reproduzível.

---

## 4. Abrir o cliente SQL

```bash
docker exec -it radar-db psql -U radar -d radar
```

Os próximos comandos SQL (passos 5 a 7) devem ser digitados **dentro** do prompt do `psql`.

> Para sair do `psql`, digite `\q`.

---

## 5. Criar as tabelas

Cole no prompt do `psql` (também disponível em [`sql/01_criar_tabelas.sql`](sql/01_criar_tabelas.sql)):

```sql
CREATE TABLE provas (
  id   SERIAL PRIMARY KEY,
  ano  INTEGER NOT NULL,
  nome TEXT NOT NULL
);

CREATE TABLE questoes (
  id          SERIAL PRIMARY KEY,
  prova_id    INTEGER NOT NULL REFERENCES provas(id),
  assunto     TEXT NOT NULL,
  enunciado   TEXT NOT NULL,
  dificuldade TEXT CHECK (
    dificuldade IN ('baixa', 'média', 'alta')
  )
);
```

📸 **Evidência:** `04_criar_tabelas.png`

---

## 6. Inserir dados de teste

Arquivo: [`sql/02_inserir_dados.sql`](sql/02_inserir_dados.sql)

```sql
INSERT INTO provas (ano, nome) VALUES
  (2025, 'ENEM regular'),
  (2024, 'ENEM regular');

INSERT INTO questoes
  (prova_id, assunto, enunciado, dificuldade)
VALUES
  (1, 'Ecologia',
   'Questão demonstrativa sobre ecossistemas', 'média'),
  (1, 'Matemática',
   'Questão demonstrativa sobre funções', 'alta'),
  (2, 'Ecologia',
   'Questão demonstrativa sobre cadeias alimentares', 'baixa');
```

📸 **Evidência:** `05_inserir_dados.png`

---

## 7. Consultar os registros

Arquivo: [`sql/03_consultas.sql`](sql/03_consultas.sql)

Confira primeiro cada tabela separadamente:

```sql
SELECT * FROM provas;
SELECT * FROM questoes;
```

Agora relacione as questões às provas usando **JOIN**:

```sql
SELECT q.id, p.ano, q.assunto, q.dificuldade
FROM questoes AS q
JOIN provas AS p ON p.id = q.prova_id
ORDER BY p.ano DESC, q.assunto;
```

📸 **Evidência:** `06_consulta_join.png`

> 📝 **Explique no relatório o papel de `prova_id`:** ele é a **chave estrangeira (FK)** em
> `questoes` que aponta para a **chave primária (PK)** `id` de `provas`, garantindo que toda questão
> pertença a uma prova existente (integridade referencial). É a coluna usada no `JOIN` para
> relacionar as duas tabelas.

Saia do `psql` com `\q`.

---

## 8. Desafio obrigatório — comprovar persistência

Remova o container, mas **NÃO** remova o volume:

```bash
docker rm -f radar-db
```

Inicie novamente o PostgreSQL utilizando o **mesmo volume**:

```bash
docker run -d \
  --name radar-db \
  -e POSTGRES_USER=radar \
  -e POSTGRES_PASSWORD=radar_lab_123 \
  -e POSTGRES_DB=radar \
  -p 5432:5432 \
  -v radar-db-dados:/var/lib/postgresql/data \
  postgres:16
```

Consulte novamente os dados a partir do terminal (sem entrar no `psql` interativo):

```bash
docker exec -it radar-db \
  psql -U radar -d radar \
  -c "SELECT q.id, p.ano, q.assunto
      FROM questoes AS q
      JOIN provas AS p ON p.id = q.prova_id;"
```

**Resultado esperado:** as provas e questões continuam disponíveis, porque os arquivos do banco
estão no **volume nomeado**, que foi reutilizado na recriação do container.

> Se ocorrer erro, verifique o estado e os logs com `docker ps` e `docker logs radar-db`.
> **Não remova o volume durante a atividade.**

📸 **Evidência:** `07_persistencia_apos_recriar.png`

---

## 9. Desafios adicionais (escolha pelo menos três)

Arquivo com todos: [`sql/05_desafios.sql`](sql/05_desafios.sql)

### A — Filtro: somente questões de Ecologia

```sql
SELECT * FROM questoes
WHERE assunto = 'Ecologia';
```

📸 `08_desafio_A_filtro.png`

### B — Atualização (confira o `id` escolhido antes)

```sql
UPDATE questoes
SET dificuldade = 'baixa'
WHERE id = 1;

SELECT * FROM questoes WHERE id = 1;
```

📸 `09_desafio_B_update.png`

### C — Integridade referencial (erro esperado de FK)

```sql
INSERT INTO questoes
  (prova_id, assunto, enunciado, dificuldade)
VALUES
  (999, 'Teste', 'Registro inválido', 'baixa');
```

> Esperado: erro de *foreign key constraint* — `prova_id=999` não existe em `provas`.

📸 `10_desafio_C_fk_erro.png`

### D — Restrição NOT NULL (erro esperado)

```sql
INSERT INTO questoes (prova_id, assunto, enunciado)
VALUES (1, NULL, 'Teste de campo obrigatório');
```

> Esperado: erro — a coluna `assunto` é `NOT NULL`.

📸 `11_desafio_D_notnull_erro.png`

### E — Backup lógico (`pg_dump`) a partir do host

Saia do `psql` com `\q` e gere um arquivo SQL no computador host:

```bash
docker exec radar-db \
  pg_dump -U radar -d radar \
  > backup-radar.sql
```

Confira se o arquivo foi criado no diretório atual:

```bash
ls -lh backup-radar.sql
```

📸 `12_desafio_E_backup.png`

### F — Modelagem (resposta no relatório)

Proponha uma tabela `assuntos` e explique como ela se relacionaria com `questoes`. Veja a proposta
em [`sql/05_desafios.sql`](sql/05_desafios.sql) e a explicação no [`RELATORIO.md`](RELATORIO.md).

### G — Segurança (resposta no relatório)

Explique por que a senha simples deste exercício não deve ser usada em produção. Resposta no
[`RELATORIO.md`](RELATORIO.md).

---

## 10. Encerramento (somente ao concluir tudo)

Depois de capturar todas as evidências e preencher o relatório:

```bash
docker rm -f radar-db
# Remova o volume APENAS se quiser descartar os dados do laboratório:
# docker volume rm radar-db-dados
```

---

## Entregáveis

1. [`RELATORIO.md`](RELATORIO.md) preenchido com os 9 itens do relatório técnico e as 8 perguntas.
2. Prints na pasta [`evidencias/`](evidencias/) (veja a lista em `evidencias/README.md`).
3. Arquivo `backup-radar.sql` gerado no Desafio E (opcional versionar).
```