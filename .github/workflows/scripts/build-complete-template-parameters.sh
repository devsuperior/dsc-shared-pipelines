#!/bin/bash

set -e  # Falha em qualquer erro do shell (usado para dar feedback ao github actions)
set -o pipefail  # Falha em qualquer erro da pipeline do shell (usado para dar feedback ao github actions)

# Remove a chave "Repository" e "EnvironmentName" se ela existir
jq 'del(.[] | select(.ParameterKey == "RepositoryName" or .ParameterKey == "EnvironmentName"))' infra/template-parameters.json > temp.json

# Adiciona a chave "Repository" e "EnvironmentName" com os valores corretos
jq --arg repoValue "$REPOSITORY_NAME" --arg envValue "$ENVIRONMENT_NAME" '. += [{"ParameterKey": "RepositoryName", "ParameterValue": $repoValue}, {"ParameterKey": "EnvironmentName", "ParameterValue": $envValue}]' temp.json > complete-template-parameters.json