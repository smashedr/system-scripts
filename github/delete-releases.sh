#!/usr/bin/env bash

# Delete all runs for a given workflow
# Usage: delete-logs.sh <repository> <workflow-name>

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

_TAGS=$(gh -R "${REPOSITORY}" release list --json tagName --jq '.[].tagName')

echo "Found $(echo "${_TAGS}" | wc -l) releases for: ${REPOSITORY}"
# shellcheck disable=SC2086
echo ${_TAGS}

until [[ $VAR =~ y|n ]];do
    read -r -p "Proceed? (y/n) " -n 1 VAR
    VAR=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]')
    echo
done

for _id in ${_IDS}; do
  echo "Deleting run ID: ${_id}"
  gh -R "${REPOSITORY}" run delete "${_id}" &&\
    echo "Success. Deleted run ID: ${_id}" ||\
    echo "FAILED to delete run ID: ${_id}"
  sleep 0.1
done

