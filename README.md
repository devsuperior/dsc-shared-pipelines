# ![DevSuperior logo](https://raw.githubusercontent.com/devsuperior/bds-assets/main/ds/devsuperior-logo-small.png) dsc-shared-pipelines

Repositório de Workflows (Pipelines/Esteiras) de CI/CD que são usados no projeto [dscommerce](https://github.com/search?q=topic%3Adscommerce+org%3Adevsuperior&type=Repositories).

Esses Workflows utilizam do GitHub Actions como meio para executar as integrações necessárias para o deploy de aplicações e infraestrutura na AWS.

Dentro do GitHub Workflows existe o recurso chamado `Reusable Workflows` ao qual permite encadear e reaproveitar workflows. É possível enviar e receber parâmetros semelhante a uma função códificada em uma linguagem qualquer.

No projeto [dscommerce](https://github.com/search?q=topic%3Adscommerce+org%3Adevsuperior&type=Repositories) convencionamos que a primeira etapa do Workflow se chama **Pipeline**. Essa primeira etapa é responsável por iniciar um fluxo com um objetivo claro, deploy de infraestrutura, deploy de lambda, dentre outros. 

Em um **Pipeline** há uma coordenação/orquestração de Workflows que cumprem o objetivo do pipeline.

Para representar os Workflows foram feitos diagramas que podem ser conferidos abaixo, **um Workflow que foi reutilizado pode ser facilmente identificado através de seu nome e cor**, por exemplo, se o Workflow de integração com o Sonar se chama `sonar-analysis` e ele tiver sido reaproveitado em outro Pipeline, ele terá esse mesmo nome em todos os pipes e a mesma cor, por exemplo, azul.

| :exclamation:  Nos repositórios de projeto é mandatório invocar apenas os Workflows do tipo Pipeline, que são identificados pelo prefixo do yml: `0.pipeline`.   |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Abaixo a especificação de cada um dos Pipelines.

## Pipeline de Deploy de Infras no Geral

```mermaid
graph TD
    INFRA[0.pipeline-infra.yml] --> A1[generate-basic-constants]
    A1 --> E1[generate-complete-template-parameters]
    A1 --> F1[check-delete-cloud-formation-status]
    E1 --> G1[deploy-cloud-formation]
    F1 --> G1

    %% Estilo
    style A1 fill:#ff6666, color:black
    style E1 fill:#6666ff, color:black
    style F1 fill:#ff9933, color:black
    style G1 fill:#cc66cc, color:black
```

O objetivo desse pipeline é realizar o deploy de qualquer infra via AWS CloudFormation que não necessite de um "step especial" de build a não ser provisionar os recursos declarados no `template.yml` do repositório chamador.

Esse pipeline também precisa do `template-parameters.json` como argumento e injeta nele duas propriedades:
- RepositoryName: nome do repositório chamador.
- EnvironmentName: nome do ambiente de acordo com a branch do repositório chamador (develop: dev, release-candidate: stg, main: prd).

[Clique aqui para acessar o pipeline](./.github/workflows/0.pipeline-infra.yml).

## Pipeline de Deploy de Serviços ECS 

```mermaid
graph TD
    ECS[0.pipeline-ecs-service.yml] --> A[generate-basic-constants]
    A --> B[build-java-gradle]
    B --> C[sonar-analysis]
    C --> D[build-push-docker-image]
    A --> E[generate-complete-template-parameters]
    D --> F[check-delete-cloud-formation-status]
    E --> G[deploy-cloud-formation]
    F --> G
    G --> H[force-deploy-ecs-task-definition]

    %% Estilo
    style A fill:#ff6666, color:black
    style B fill:#338833, color:black
    style C fill:#3333ff, color:black
    style E fill:#6666ff, color:black
    style F fill:#ff9933, color:black
    style G fill:#cc66cc, color:black

```

O objetivo desse pipeline é realizar o deploy de microservices, ou qualquer outro tipo de serviço orquestrado pelo AWS Elastic Container Service via AWS CloudFormation.

**Os serviços que utilizam essa pipeline devem obrigatoriamente utilizar Java 17, Gradle e Docker.**

Esse pipeline faz o build com Java 17 e Gradle, submete o código para análise do Sonar, cria uma nova imagem Docker no AWS Elastic Container Registry, tenta realizar o deploy via AWS Cloudformation, mas caso não exista mudanças no `template.yml` força um novo deployment com a imagem latest versionada no AWS Elastic Container Registry. 

Esse pipeline também precisa do `template-parameters.json` como argumento e injeta nele duas propriedades:
- RepositoryName: nome do repositório chamador.
- EnvironmentName: nome do ambiente de acordo com a branch do repositório chamador (develop: dev, release-candidate: stg, main: prd).

[Clique aqui para acessar o pipeline](./.github/workflows/0.pipeline-ecs-service.yml).

## Pipeline de Deploy de Lambdas Java

```mermaid
graph TD
    LAMBDA[0.pipeline-lambda.yml] --> A2[generate-basic-constants]
    LAMBDA --> B2[build-java-gradle]    
    A2 --> C2[build-sam]
    A2 --> D2
    B2 --> D2[sonar-analysis]
    D2 --> F2[check-delete-cloud-formation-status]
    C2 --> F2
    F2 --> G2[deploy-sam]

    %% Estilo
    style A2 fill:#ff6666, color:black
    style B2 fill:#338833, color:black
    style D2 fill:#3333ff, color:black
    style F2 fill:#ff9933, color:black
    style G2 fill:#cc66cc, color:black

```

O objetivo desse pipeline é realizar o deploy de microservices no formato AWS Lambda com tecnologia Java 17 ou GraalVM nativo via AWS SAM.

**Para AWS Lambda Convencional, os serviços que utilizam essa pipeline devem obrigatoriamente utilizar Java 17, Gradle.**

**Para AWS Lambda Imagem Nativa, os serviços que utilizam essa pipeline devem obrigatoriamente a imagem Docker oficial da AWS para Build com GraalVM.**

Esse pipeline utiliza o AWS SAM como template, semelhante ao AWS Cloudformation mas possui facilitadores para build e deploy. Antes de se integrar com esse pipeline certifique-se que o projeto está configurado corretamente com AWS SAM.

Esse pipeline faz o build com Java 17 e Gradle, submete o código para análise do Sonar, faz o build com AWS SAM, tenta realizar o deploy com AWS SAM, mas caso não exista mudanças no `template.yml` força um novo deployment do lambda.

Os lambdas ditos como "Convencionais" são habilitados automaticamente no SnapStart da AWS Lambda.

Todos os lambdas quando publicados recebem uma tag de invocação chamada "target" que aponta pra última versão.

Esse pipeline NÃO precisa do `template-parameters.json` como argumento ele injeta diretamente no `template.yml` duas propriedades:
- RepositoryName: nome do repositório chamador.
- EnvironmentName: nome do ambiente de acordo com a branch do repositório chamador (develop: dev, release-candidate: stg, main: prd).

[Clique aqui para acessar o pipeline](./.github/workflows/0.pipeline-lambda.yml).

## Pipeline de Verificação de Pull Request no Sonar

```mermaid
graph TD
    SONARQUBE[0.pipeline-pull-request.yml] --> A[build-java-gradle]
    A --> B[sonar-analysis]
    B --> C[comment]

    %% Estilo
    style A fill:#338833, color:black
    style B fill:#3333ff, color:black

```

O objetivo desse pipeline é realizar a análise do projeto antes que o commit merge seja realizado (etapa de Pull Request) para uma das branchs de destino reservadas (develop, release-candidate, main).

Esse pipeline é aplicável apenas à microservices que sejam possíveis de construir usando Java 17 e Gradle.

Após abrir um "PR" para as branch reservadas o pipeline se inicia e como resultado é adicionado um novo comentário ao Pull Request semelhante a esse abaixo:

![Comentário no Pull Request](assets/images/pull-request-comment.png)

Baseado no resultado pode-se tomar a decisão de aprovar ou não o Pull Request.

[Clique aqui para acessar o pipeline](./.github/workflows/0.pipeline-pull-request.yml).
