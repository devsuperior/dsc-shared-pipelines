#!/bin/bash

set -e  # Falha em qualquer erro do shell (usado para dar feedback ao github actions)
set -o pipefail  # Falha em qualquer erro da pipeline do shell (usado para dar feedback ao github actions)

echo "Verificando o status da stack: $STACK_NAME"

# Verifica se a stack existe
stack_exists=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks' --output text 2>/dev/null)
stack_id=""
event=""
status=""

if [[ -z $stack_exists ]]; then
  echo "A stack $STACK_NAME nao existe. Nenhuma acao necessaria."
else
  # Obtem o ID do stack
  stack_id=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].StackId' --output text)

  echo "ID da stack: $stack_id"

  # Obtem o evento mais recente da stack
  event=$(aws cloudformation describe-stack-events --stack-name $stack_id --query 'StackEvents[0]' --output json)

  # Verifica se ha eventos na stack
  if [[ -z $event ]]; then
    echo "Nao ha eventos disponiveis para a stack $STACK_NAME."
  else
    # Obtem o status mais recente da stack
    status=$(echo "$event" | jq -r '.ResourceStatus')
    echo "Status atual da stack: $status"
  fi

fi

# Verifica se o status eh "ROLLBACK_COMPLETE" ou "UPDATE_ROLLBACK_COMPLETE"
if [[ $status == *"IN_PROGRESS" || 
      $status == *"FAILED" || 
      $status == "ROLLBACK_COMPLETE" || 
      $status == "UPDATE_ROLLBACK_COMPLETE"
]]; then
  echo "A stack esta no estado $status. Entrou na condicional de espera."

  if [[ $status != *"IN_PROGRESS" ]]; then
    echo "A stack esta no estado $status. Iniciando a exclusao da stack..."
    aws cloudformation delete-stack --stack-name $stack_id
  fi

  echo "Aguardando a alteracao de estado da stack..."

  sleep 10s  # Aguarda 10 segundos antes de iniciar o loop while

  # Aguarda ate que o status seja "DELETE_IN_PROGRESS"
  while [[ $status == *"IN_PROGRESS" ]]; do
    sleep 10s  # Aguarda 10 segundos antes de verificar o status novamente

    # Obtem o evento mais recente da stack
    event=$(aws cloudformation describe-stack-events --stack-name $stack_id --query 'StackEvents[0]' --output json)

    # Verifica se a stack ainda existe
    if [[ -z $event ]]; then
      echo "A stack $STACK_NAME nao existe mais. Exclusao completa."
      exit 0
    fi

    # Obtem o status mais recente da stack
    status=$(echo "$event" | jq -r '.ResourceStatus')

    echo "Status atual da stack: $status"
  done

else
  echo "A stack esta em um estado valido para prosseguir."
fi