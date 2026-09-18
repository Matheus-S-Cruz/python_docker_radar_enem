# RUNBOOK — Radar ENEM

## 1. Descrição

O Radar ENEM é uma aplicação Flask conteinerizada utilizada para simular práticas de operação em ambiente de produção, incluindo health check, monitoramento, recuperação e versionamento.

## 2. Pré-requisitos

- Docker Desktop / Docker Engine
- Docker Compose
- Terminal ou VS Code

## 3. Configuração

Variáveis utilizadas:

- `AMBIENTE`
- `REGIAO`
- `VERSAO`

## 4. Inicialização

```bash
docker compose build
docker compose up -d
docker compose ps
```

## 5. Health check

Endpoint:

```text
http://localhost:5000/health
```

Comando:

```bash
curl http://localhost:5000/health
```

```text
{
  "servico": "radar-enem",
  "status": "healthy",
  "versao": "v2"
}
```

## 6. Logs

```bash
docker logs radar-enem
```

Informação relevante encontrada:

```text
Os logs registraram as requisições HTTP realizadas aos endpoints /, /health e /status, permitindo acompanhar o comportamento da aplicação durante a execução.
```

## 7. Monitoramento

```bash
docker stats radar-enem
```

CPU e Memória observada:

```text
NAME radar-enem
CPU % 0.02%
MEM USAGE / LIMIT 23.16MiB / 7.415GiB
MEM % 0.30%
```

## 8. Recuperação

Primeiro investigar:

```bash
docker ps
docker ps -a
docker logs radar-enem
docker inspect radar-enem
```

## 9. Atualização

Após realizar uma alteração pequena e identificável, gerar a nova imagem:

```bash
docker build -t radar-enem:v3 .
docker stop radar-enem
docker rm radar-enem
```

Executar a nova versão:

```bash
docker run -d --name radar-enem -p 5000:5000 -e AMBIENTE=producao -e REGIAO=Brasil -e VERSAO=v3 radar-enem:v3
```

Validar:

```bash
curl http://localhost:5000/health
curl http://localhost:5000/status
```

Alteração realizada entre v2 e v3:

```text
health
Content           : {"servico":"radar-enem","status":"healthy","versao":"v3"}

status
Content           : {"ambiente":"producao","projeto":"Radar ENEM","regiao":"Brasil","status":"funcionando","versao":"v3"}
```

## 10. Rollback

Se a nova versão apresentar problema:

```bash
docker stop radar-enem
docker rm radar-enem
docker run -d --name radar-enem -p 5000:5000 -e AMBIENTE=producao -e REGIAO=Brasil -e VERSAO=v2 radar-enem:v2
```

Depois validar novamente o `/health`.

## 11. Portas

- Porta `5000`: acesso à aplicação Radar ENEM.