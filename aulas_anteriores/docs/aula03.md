# Aula 03 - Mini Radar ENEM com Python e Docker

## 1. O que foi necessário instalar e configurar para executar a aplicação sem Docker?
Para executar a aplicação sem Docker, foi necessário ter o Python instalado no computador e criar um ambiente virtual para o projeto. Depois, instalamos o Flask usando o arquivo "requirements.txt", que contém as dependências necessárias para a aplicação.

Também foi necessário executar o arquivo "app.py" e deixar a aplicação funcionando na porta 5000. Dessa forma, foi possível acessar a API pelo navegador usando "http://localhost:5000".

## 2. O que o Docker passou a empacotar ou padronizar?
O Docker passou a reunir em uma imagem o ambiente necessário para executar a aplicação. O "Dockerfile" define a imagem base do Python, o diretório de trabalho, as dependências do projeto, o código da aplicação, a porta utilizada e o comando que inicia o programa.

Com isso, a aplicação fica mais fácil de executar em outros computadores, pois o ambiente necessário fica padronizado dentro do container. No nosso caso, criamos as imagens "radar-enem:v1" e "radar-enem:v2".

## 3. Se o container for executado em uma VM IaaS, quais responsabilidades ainda ficam com a equipe?
Mesmo utilizando um container dentro de uma VM em um ambiente IaaS, a equipe ainda possui várias responsabilidades. Entre elas estão o gerenciamento da máquina virtual, do sistema operacional, das atualizações e patches, do Docker, das configurações e da própria aplicação.

O provedor de nuvem fica responsável principalmente pela infraestrutura física e pela virtualização. Portanto, usar Docker não significa que toda a parte de infraestrutura deixa de ser responsabilidade da equipe.

## 4. O que um PaaS poderia assumir automaticamente?
Em um modelo PaaS, a plataforma pode assumir grande parte do gerenciamento da infraestrutura. Isso pode incluir o sistema operacional, o runtime, a disponibilidade da plataforma e outras tarefas relacionadas ao ambiente de execução.

Assim, a equipe consegue se concentrar mais no desenvolvimento da aplicação, nos dados e nas configurações, sem precisar administrar diretamente todas as camadas de infraestrutura. Isso reduz o trabalho operacional, mas também diminui o controle direto sobre o ambiente.

## 5. Por que Docker não pode ser classificado, sozinho, como IaaS, PaaS ou SaaS?
O Docker não é um modelo de serviço de nuvem, é uma tecnologia utilizada para empacotar e executar aplicações em containers.

Um container ajuda a resolver problemas relacionados ao empacotamento e à portabilidade da aplicação, mas ainda existem outras camadas, como sistema operacional, infraestrutura, rede e disponibilidade. Essas responsabilidades variam de acordo com o modelo de serviço utilizado.

Por isso, Docker pode ser utilizado dentro de diferentes ambientes, inclusive em soluções de IaaS e PaaS, mas não deve ser considerado, por si só, como IaaS, PaaS ou SaaS.

## Conclusão

A atividade mostrou na prática como uma aplicação Python pode ser transformada em um serviço conteinerizado. Primeiro executamos a aplicação diretamente com Python e Flask e, depois, criamos uma imagem Docker para padronizar o ambiente de execução.

Também foi possível perceber a diferença entre as responsabilidades em IaaS e PaaS. Quanto maior a abstração oferecida pela plataforma, menor tende a ser o trabalho operacional da equipe, enquanto o controle direto sobre a infraestrutura também diminui.