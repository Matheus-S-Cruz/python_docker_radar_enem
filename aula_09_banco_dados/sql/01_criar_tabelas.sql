-- Aula 9 — Passo 5: criar as tabelas relacionadas (Mini Radar ENEM)
-- Executar dentro do psql:  docker exec -it radar-db psql -U radar -d radar
-- ou direto:                docker exec -i radar-db psql -U radar -d radar < sql/01_criar_tabelas.sql

-- Tabela "pai": cada prova tem uma chave primária (PK) própria.
CREATE TABLE provas (
  id   SERIAL PRIMARY KEY,   -- PK: identificador único, auto incremento
  ano  INTEGER NOT NULL,
  nome TEXT NOT NULL
);

-- Tabela "filha": cada questão pertence a uma prova via chave estrangeira (FK).
CREATE TABLE questoes (
  id          SERIAL PRIMARY KEY,
  prova_id    INTEGER NOT NULL REFERENCES provas(id),  -- FK -> provas(id)
  assunto     TEXT NOT NULL,
  enunciado   TEXT NOT NULL,
  dificuldade TEXT CHECK (
    dificuldade IN ('baixa', 'média', 'alta')          -- restrição de domínio
  )
);