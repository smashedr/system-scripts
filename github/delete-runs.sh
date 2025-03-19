#!/usr/bin/env bash

# Delete all runs for a given workflow
# Usage: delete-runs.sh <repository> <workflow-name>

set -oe pipefail

REPOSITORY=$1
WORKFLOW=$2

# Validate arguments
if [[ -z "${REPOSITORY}" ]]; then
  echo "Repository is required"
  exit 1
fi

if [[ -z "${WORKFLOW}" ]]; then
  echo "Workflow name is required"
  exit 1
fi

echo "Getting all runs for: ${REPOSITORY}/${WORKFLOW}"

_IDS=$(gh -R "${REPOSITORY}" run list -w "${WORKFLOW}" --json databaseId --jq '.[].databaseId')

echo "Found $(echo "${_IDS}" | wc -l) runs for: ${WORKFLOW}"

until [[ ${VAR} =~ y|n ]];do
    read -r -p "Proceed? (y/n) " VAR
    VAR=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]')
    echo
done
[[ ${VAR} != "y" ]] && exit 1

for _id in ${_IDS}; do
  echo "Deleting run ID: ${_id}"
  gh -R "${REPOSITORY}" run delete "${_id}" &&\
    echo "Success. Deleted run ID: ${_id}" ||\
    echo "FAILED to delete run ID: ${_id}"
  sleep 0.1
done

