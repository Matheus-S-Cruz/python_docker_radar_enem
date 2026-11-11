# Evidências — Aula 9 (Banco de Dados Relacional com PostgreSQL)

Coloque aqui os **prints de tela** (ou saídas em `.txt`) capturados **após cada comando** indicado no
[`../README.md`](../README.md). A numeração dos arquivos segue a ordem do roteiro.

| Arquivo | Capturado após o comando / passo | O que o print mostra | Status |
|---|---|---|---|
| `01_docker_version.png` | `docker --version` (passo 1) | Docker 29.9.2 disponível | ✅ capturado |
| `02_volume_criado.png` | `docker volume create` + `docker volume ls` (passo 2) | Volume `radar-db-dados` listado | ✅ capturado |
| `03_postgres_rodando.png` | `docker run ... postgres:16` + `docker ps` (passo 3) | Container `radar-db` com status `Up` | ✅ capturado |
| `04_criar_tabelas.png` | `CREATE TABLE provas / questoes` (passo 5) | Mensagens `CREATE TABLE` no psql | ✅ capturado |
| `05_inserir_dados.png` | `INSERT INTO ...` (passo 6) | `INSERT 0 2` e `INSERT 0 3` | ✅ capturado |
| `06_consulta_join.png` | `SELECT ... JOIN ...` (passo 7) | As 3 questões com ano/assunto/dificuldade | ✅ capturado |
| `07_persistencia_apos_recriar.png` | `docker rm -f` → `docker run` → `SELECT ... JOIN` (passo 8) | **Dados ainda presentes** após recriar o container | ✅ capturado |
| `08_desafio_A_filtro.png` | Desafio A — filtro Ecologia | Apenas questões de Ecologia (ids 1 e 3) | ✅ capturado |
| `09_desafio_B_update.png` | Desafio B — `UPDATE` + `SELECT` | `UPDATE 1` e a linha atualizada | ✅ capturado |
| `10_desafio_C_fk_erro.png` | Desafio C — `INSERT` com `prova_id=999` | Erro de *foreign key constraint* `questoes_prova_id_fkey` | ✅ capturado |
| `11_desafio_D_notnull_erro.png` | Desafio D — `INSERT` com `assunto NULL` | Erro de *not-null constraint* | ⬜ não executado (opcional) |
| `12_desafio_E_backup.png` | Desafio E — `pg_dump` + `ls -lh backup-radar.sql` | Arquivo `backup-radar.sql` criado | ⬜ não executado (opcional) |

> Foram executados os desafios **A, B e C** (mínimo de três atendido). D e E ficam como opcionais.

> **Dica:** no passo que mostra erro **esperado** (C), o print do erro **é** a evidência — ele
> comprova que o banco protege a integridade dos dados (rejeita FK inexistente).

> Formatos aceitos: `.png`, `.jpg` para prints; `.txt` para saídas de terminal, se preferir anexar
> o texto além da imagem.

O [`../RELATORIO.md`](../RELATORIO.md) já está preenchido com as saídas reais desta execução
(Docker 29.9.2 / PostgreSQL 16.15).
