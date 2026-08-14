# Mini Radar ENEM — Python + Docker
Atividade prática da disciplina de **Computação em Nuvem**, com o objetivo de desenvolver uma pequena API em Python utilizando Flask, criar uma imagem Docker e executar a aplicação dentro de um container.

A atividade também aborda os conceitos de **IaaS, PaaS, SaaS e responsabilidade compartilhada**, mostrando quais responsabilidades permanecem com a equipe quando uma aplicação é executada em diferentes modelos de serviço em nuvem.

## Objetivos da atividade
Durante a atividade, foram desenvolvidas as seguintes etapas:

* Executar uma aplicação Python com Flask sem utilizar Docker;
* Criar um `Dockerfile` para a aplicação;
* Construir uma imagem Docker;
* Executar a aplicação dentro de um container;
* Trabalhar com mapeamento de portas;
* Utilizar variáveis de ambiente;
* Criar uma segunda versão da aplicação (`v2`);
* Adicionar novos endpoints;
* Observar o funcionamento e os logs do container;
* Relacionar o uso de containers aos modelos IaaS e PaaS.

## Tecnologias utilizadas
* **Python 3.12**
* **Flask 3.x**
* **Docker**
* **Docker Desktop**
* **PowerShell**
* **Git/GitHub**

## Estrutura do projeto
```text
radarenem/
│
├── app.py
├── requirements.txt
├── Dockerfile
│
└── docs/
    └── aula03.md
```

### Principais arquivos
**`app.py`**

Contém a API desenvolvida com Flask e seus endpoints.

**`requirements.txt`**

Define a dependência necessária para executar a aplicação:

```text
Flask>=3.0,<4.0
```

**`Dockerfile`**

Define como a imagem Docker da aplicação deve ser construída.

**`docs/aula03.md`**

Contém as respostas das questões conceituais propostas na atividade.

---

# Como executar
## 1. Clonar o repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd radarenem
```

## 2. Criar o ambiente virtual

No Windows:

```powershell
python -m venv venv
```

Ativar o ambiente virtual:

```powershell
venv\Scripts\Activate.ps1
```

## 3. Instalar as dependências

```powershell
pip install -r requirements.txt
```

## 4. Executar sem Docker

```powershell
python app.py
```

A aplicação será executada na porta `5000`.

Pode ser acessada pelo navegador em:

```text
http://localhost:5000
```

Também podem ser testados:

```text
http://localhost:5000/health
```

```text
http://localhost:5000/aluno/Matheus
```

---

# Executando com Docker
## 1. Construir a imagem

Para a primeira versão:

```powershell
docker build -t radar-enem:v1 .
```

Para a versão final da atividade:

```powershell
docker build -t radar-enem:v2 .
```

Verificar as imagens disponíveis:

```powershell
docker images
```

## 2. Executar o container

A versão `v2` pode ser executada com:

```powershell
docker run --rm -p 5000:5000 radar-enem:v2
```

A aplicação ficará disponível em:

```text
http://localhost:5000
```

### Testando o endpoint da versão 2
A versão `v2` possui o endpoint:

```text
/nota/<nota>
```

Por exemplo:

```text
http://localhost:5000/nota/650
```

Resultado esperado:

```json
{
    "nota": 650,
    "classificacao": "acima de 600"
}
```

Também pode ser testado um valor abaixo de 600:

```text
http://localhost:5000/nota/500
```

Resultado:

```json
{
    "nota": 500,
    "classificacao": "abaixo de 600"
}
```

> A classificação utilizada é apenas uma regra didática proposta na atividade e não representa uma análise estatística real dos Microdados do ENEM.

---

# Mapeamento de portas
O Docker permite utilizar uma porta diferente no computador sem alterar a porta utilizada pela aplicação dentro do container.

Por exemplo:

```powershell
docker run --rm -p 8080:5000 radar-enem:v2
```

Nesse caso:

```text
Computador       Container
   8080   --->      5000
```

A aplicação continua utilizando a porta `5000` dentro do container, mas pode ser acessada pelo computador através da porta `8080`:

```text
http://localhost:8080
```

---

# Variáveis de ambiente
A aplicação utiliza variáveis de ambiente para permitir configurações sem precisar alterar diretamente o código.

Exemplo:

```powershell
docker run --rm -p 8080:5000 -e AMBIENTE=producao radar-enem:v2
```

Dessa forma, a aplicação pode receber configurações diferentes dependendo do ambiente em que está sendo executada.

---

# Logs e ciclo de vida do container
Também é possível executar o container em segundo plano:

```powershell
docker run -d --name radar-enem -p 5000:5000 radar-enem:v2
```

Verificar os containers em execução:

```powershell
docker ps
```

Visualizar os logs:

```powershell
docker logs radar-enem
```

Parar o container:

```powershell
docker stop radar-enem
```

Iniciar novamente:

```powershell
docker start radar-enem
```

Remover o container:

```powershell
docker rm radar-enem
```

---

# IaaS, PaaS e Docker
A atividade também teve como objetivo entender a relação entre containers e os modelos de serviço em nuvem.

No modelo **IaaS**, a equipe normalmente ainda é responsável pela máquina virtual, sistema operacional, atualizações, Docker, configurações e aplicação. O provedor fica responsável pela infraestrutura física e pela virtualização.

No **PaaS**, a plataforma assume uma parte maior da infraestrutura, permitindo que a equipe se concentre principalmente na aplicação, nos dados e nas configurações.

O **Docker não é, sozinho, IaaS, PaaS ou SaaS**. Ele é uma tecnologia utilizada para empacotar e executar aplicações em containers. As responsabilidades sobre infraestrutura, disponibilidade, sistema operacional e outros componentes dependem do ambiente onde o container está sendo executado.

---

# Evidências da atividade
As evidências da execução da atividade estão disponíveis na documentação do projeto:

📄 [Documentação da atividade](docs/aula03.md)

Nela estão apresentadas as respostas das questões propostas pelo professor e as capturas de tela da execução da aplicação e do container.

---

# Entrega
A entrega final contém:

* `app.py`
* `requirements.txt`
* `Dockerfile`
* `docs/aula03.md`
* Evidências da execução da versão `v2`

A atividade foi desenvolvida com base no roteiro da disciplina **Computação em Nuvem — Aula 3: Mini Radar ENEM com Python e Docker**.

# Integrantes
- Matheus Silva da Cruz
- João Paulo
- Nicolas André
