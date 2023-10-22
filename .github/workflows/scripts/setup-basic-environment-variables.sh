#!/bin/bash

set -e  # Falha em qualquer erro do shell (usado para dar feedback ao github actions)
set -o pipefail  # Falha em qualquer erro da pipeline do shell (usado para dar feedback ao github actions)

# Environment name
if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
  echo "ENVIRONMENT_NAME=prd" >> $GITHUB_ENV
elif [[ "${{ github.ref }}" == "refs/heads/release-candidate" ]]; then
  echo "ENVIRONMENT_NAME=uat" >> $GITHUB_ENV
elif [[ "${{ github.ref }}" == "refs/heads/develop" ]]; then
  echo "ENVIRONMENT_NAME=dev" >> $GITHUB_ENV
else
  echo "Unknown branch. Not setting ENV_NAME."
  exit 1
fi

# Repository name
echo "REPOSITORY_NAME=${{ github.event.repository.name }}" >> $GITHUB_ENV
