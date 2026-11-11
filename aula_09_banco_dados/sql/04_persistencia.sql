-- Aula 9 — Passo 8: consulta de comprovação de persistência
-- Rodar DEPOIS de remover o container e recriá-lo apontando para o MESMO volume.
--
--   docker rm -f radar-db
--   docker run -d --name radar-db -e POSTGRES_USER=radar -e POSTGRES_PASSWORD=radar_lab_123 \
--     -e POSTGRES_DB=radar -p 5432:5432 -v radar-db-dados:/var/lib/postgresql/data postgres:16
--
-- Se os dados aparecerem, a persistência via volume nomeado está comprovada.

SELECT q.id, p.ano, q.assunto
FROM questoes AS q
JOIN provas AS p ON p.id = q.prova_id;