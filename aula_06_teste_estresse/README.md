# Teste de Estresse - Radar ENEM

Projeto acadêmico baseado no guia **Aprofundamento Técnico: PaaS, FaaS e Testes de Estresse**. A prática separa uma aplicação web Flask (simulação de PaaS) de uma API de cálculo FastAPI (simulação de FaaS), aplica carga com Locust e demonstra resiliência com timeout e mensagens de degradação graciosa.

## O que será testado

- Aplicação web Flask disponível em `http://localhost:5000`.
- API FastAPI disponível em `http://localhost:8000`.
- Documentação interativa da API em `http://localhost:8000/docs`.
- Interface do Locust disponível em `http://localhost:8089`.
- Comparação da API executada com 1 worker e com 4 workers.
- Comportamento da aplicação quando a calculadora fica lenta ou indisponível.

## Pré-requisitos

1. Instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Abra o Docker Desktop e aguarde o mecanismo ficar ativo.
3. Instale o [Visual Studio Code](https://code.visualstudio.com/).
4. No VS Code, abra a pasta `teste-estresse-radar-enem` (a pasta que contém este README).

Não é necessário instalar Python ou bibliotecas Python no computador: os containers fazem isso.

## Estrutura

```text
teste-estresse-radar-enem/
|-- api/
|   |-- Dockerfile
|   |-- main.py
|   `-- requirements.txt
|-- web/
|   |-- templates/index.html
|   |-- Dockerfile
|   |-- app.py
|   `-- requirements.txt
|-- evidencias/
|   `-- README.md
|-- .gitignore
|-- docker-compose.yml
|-- locustfile.py
`-- README.md
```

## Execução do zero - teste com 1 worker

Abra um terminal no VS Code (`Terminal > New Terminal`) e confirme que está na pasta do projeto.

```bash
docker compose build
docker compose up -d
docker compose ps
```

O arquivo `docker-compose.yml` usa **1 worker por padrão**, que será o baseline.

1. Abra `http://localhost:5000` e faça um cálculo.
2. Abra `http://localhost:8089`.
3. Preencha, por exemplo:
   - Number of users: `100`
   - Ramp up: `10`
   - Host: `http://calculadora:8000`
4. Clique em **Start swarming**.
5. Aguarde cerca de 1 minuto e registre as métricas e os gráficos.
6. Clique em **Stop** antes do próximo cenário.

## Envio ao GitHub

Depois de executar os testes e adicionar as evidências:

```bash
git init
git add .
git commit -m "Adiciona atividade de teste de estresse"
git branch -M main
git remote add origin URL_DO_SEU_REPOSITORIO
git push -u origin main
```

Substitua `URL_DO_SEU_REPOSITORIO` pela URL fornecida pelo GitHub. Não envie arquivos com senhas, tokens ou dados pessoais.