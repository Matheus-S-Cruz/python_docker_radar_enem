-- Aula 9 — Passo 7: consultar os registros

-- Conferir cada tabela separadamente
SELECT * FROM provas;
SELECT * FROM questoes;

-- Relacionar questões às provas usando JOIN.
-- prova_id (FK) em "questoes" é casado com id (PK) em "provas".
SELECT q.id, p.ano, q.assunto, q.dificuldade
FROM questoes AS q
JOIN provas AS p ON p.id = q.prova_id
ORDER BY p.ano DESC, q.assunto;