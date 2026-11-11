-- Aula 9 — Passo 9: desafios adicionais (escolha ao menos três).
-- Rode os blocos individualmente para observar cada comportamento.

-- =====================================================================
-- A — FILTRO: somente questões de Ecologia
-- =====================================================================
SELECT * FROM questoes
WHERE assunto = 'Ecologia';

-- =====================================================================
-- B — ATUALIZAÇÃO: alterar a dificuldade de uma questão (confira o id antes)
-- =====================================================================
UPDATE questoes
SET dificuldade = 'baixa'
WHERE id = 1;

SELECT * FROM questoes WHERE id = 1;

-- =====================================================================
-- C — INTEGRIDADE REFERENCIAL: inserir questão com prova_id inexistente.
--     ESPERADO: erro de foreign key (prova_id=999 não existe em provas).
-- =====================================================================
INSERT INTO questoes
  (prova_id, assunto, enunciado, dificuldade)
VALUES
  (999, 'Teste', 'Registro inválido', 'baixa');

-- =====================================================================
-- D — RESTRIÇÃO NOT NULL: inserir questão sem assunto.
--     ESPERADO: erro — a coluna "assunto" é NOT NULL.
-- =====================================================================
INSERT INTO questoes (prova_id, assunto, enunciado)
VALUES (1, NULL, 'Teste de campo obrigatório');

-- =====================================================================
-- E — BACKUP LÓGICO: executar NO HOST (fora do psql), não aqui:
--     docker exec radar-db pg_dump -U radar -d radar > backup-radar.sql
--     ls -lh backup-radar.sql
-- =====================================================================

-- =====================================================================
-- F — MODELAGEM (proposta): tabela "assuntos" normalizando o campo texto.
--     Em vez de repetir o texto do assunto em cada questão, usaríamos uma FK.
--     (Explicação completa no RELATORIO.md)
-- =====================================================================
-- CREATE TABLE assuntos (
--   id   SERIAL PRIMARY KEY,
--   nome TEXT NOT NULL UNIQUE
-- );
-- ALTER TABLE questoes ADD COLUMN assunto_id INTEGER REFERENCES assuntos(id);
-- -- Relação: 1 assunto -> N questões (um-para-muitos), via questoes.assunto_id -> assuntos.id.