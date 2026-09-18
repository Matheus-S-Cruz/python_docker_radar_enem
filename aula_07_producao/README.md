# Aula 07 — Radar ENEM em Produção

Atividade prática da disciplina de Computação em Nuvem utilizando o Radar ENEM como aplicação de laboratório.

Nesta aula, o objetivo é praticar procedimentos de operação de uma aplicação conteinerizada, incluindo configuração externa, health check, observabilidade, segurança, recuperação após incidente, atualização de versão e rollback.

## Arquivos

- `app.py`: aplicação Flask.
- `Dockerfile`: criação da imagem.
- `docker-compose.yml`: execução e health check do serviço.
- `.env.example`: exemplo das variáveis externas.
- `.dockerignore`: evita arquivos desnecessários na imagem.
- `requirements.txt`: dependências Python.

## Configurações externas

| Variável | Finalidade | Padrão |
|---|---|---|
| `AMBIENTE` | Ambiente de execução | `producao` no Compose |
| `REGIAO` | Região da aplicação | `Brasil` |
| `VERSAO` | Identificação da versão | `v2` |

Não devem ser colocadas credenciais reais nesses arquivos.

## Executar com Docker Compose

Na pasta `aula_07_producao`:

```bash
docker compose build
docker compose up -d
docker compose ps
```

A aplicação estará disponível em:

- `http://localhost:5000`
- `http://localhost:5000/health`
- `http://localhost:5000/status`

## Observabilidade

```bash
docker logs radar-enem
docker stats radar-enem
docker inspect radar-enem
```

## Encerrar

```bash
docker compose down
```

Os registros, prints, respostas da reflexão e documentação operacional podem ser adicionados posteriormente conforme a execução da atividade.
