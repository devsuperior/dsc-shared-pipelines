# dsc-shared-pipelines
Repositório de Workflows


## Template de Deploy de Infras no Geral

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

## Template de Deploy de Serviços ECS 

```mermaid
graph TD
    ECS[0.pipeline-ecs-service.yml] --> A[generate-basic-constants]
    A --> B[build-java-gradle]
    B --> C[sonar-analysis]
    C --> D[build-push-docker-image]
    A --> E[generate-complete-template-parameters]
    A --> F[check-delete-cloud-formation-status]
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

## Template de Deploy de Lambdas Java

```mermaid
graph TD
    LAMBDA[0.pipeline-lambda.yml] --> A2[generate-basic-constants]
    A2 --> B2[build-java-gradle]
    A2 --> C2[build-sam]
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

## Template de Verificação de Pull Request no Sonar

```mermaid
graph TD
    SONARQUBE[0.pipeline-pull-request.yml] --> A[build-java-gradle]
    A --> B[sonar-analysis]
    B --> C[comment]

    %% Estilo
    style A fill:#338833, color:black
    style B fill:#3333ff, color:black

```