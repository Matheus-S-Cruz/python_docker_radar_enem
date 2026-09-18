# Reflexão Final — Aula 07

## 1. Qual foi a principal diferença entre simplesmente executar um container e operar uma aplicação?
Executar um container é apenas colocar a aplicação para funcionar. Operar uma aplicação envolve também acompanhar seu funcionamento, verificar logs e recursos, identificar possíveis falhas, recuperar o serviço e controlar suas configurações e versões.

## 2. Como o health check ajuda a detectar problemas?
O health check permite verificar se a aplicação está disponível e respondendo corretamente. No Radar ENEM utilizamos o endpoint /health, que facilita identificar quando o serviço está funcionando ou quando ocorreu alguma indisponibilidade.

## 3. Por que os logs são importantes durante um incidente?
Os logs registram informações sobre a execução da aplicação e as requisições realizadas. Durante um incidente, eles ajudam a investigar o que estava acontecendo antes da falha e fornecem informações que podem ajudar a encontrar sua causa.

## 4. O que deve ser observado antes de aumentar ou reduzir recursos?
Devem ser observados dados como uso de CPU, memória e comportamento da aplicação durante sua utilização. Com essas informações é possível avaliar se os recursos atuais estão adequados antes de realizar alguma alteração.

## 5. Qual configuração vocês retiraram do código e transformaram em configuração externa?
Utilizamos variáveis de ambiente para fornecer configurações externamente. No projeto foram utilizadas AMBIENTE, REGIAO e VERSAO, permitindo alterar essas informações sem precisar modificar diretamente o código da aplicação.

## 6. Qual seria a diferença entre esse processo em uma VM IaaS e em uma plataforma PaaS?
Em uma VM IaaS, a equipe possui maior responsabilidade sobre a infraestrutura, como sistema operacional, Docker, configurações de rede e execução da aplicação. Em uma plataforma PaaS, parte dessas tarefas de infraestrutura fica sob responsabilidade da plataforma, enquanto a equipe pode se concentrar mais na aplicação e em suas configurações.

## 7. O que mudaria se o serviço estivesse distribuído em várias instâncias?
Seria necessário coordenar as diferentes instâncias e distribuir as requisições entre elas. Também seria importante acompanhar a saúde e os recursos de cada instância, além de considerar como realizar atualizações sem deixar todo o serviço indisponível.

## 8. Quais responsabilidades continuariam sendo da equipe em um serviço gerenciado?
Mesmo utilizando um serviço gerenciado, a equipe continuaria responsável pelo código da aplicação, configurações, controle de acesso adequado, atualização das versões, análise dos logs e monitoramento do comportamento da aplicação. A equipe também precisaria acompanhar o funcionamento do serviço e responder a problemas relacionados à aplicação.