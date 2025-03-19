#!/usr/bin/env bash

# Delete all logs for a given workflow
# Usage: delete-logs.sh <repository> <workflow-name>

set -oe pipefail

REPOSITORY=$1
WORKFLOW_NAME=$2

# Validate arguments
if [[ -z "${REPOSITORY}" ]]; then
  echo "Repository is required"
  exit 1
fi

if [[ -z "${WORKFLOW_NAME}" ]]; then
  echo "Workflow name is required"
  exit 1
fi

echo "Getting all completed runs for workflow ${WORKFLOW_NAME} in ${REPOSITORY}"

RUNS=$(
  gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${REPOSITORY}/actions/workflows/${WORKFLOW_NAME}/runs" \
    --paginate \
    --jq '.workflow_runs[] | select(.conclusion != "") | .id'
)

echo "Delete $(echo "${RUNS}" | wc -l) completed runs for workflow ${WORKFLOW_NAME}"

until [[ $VAR =~ y|n ]];do
    read -r -p "Proceed? (y/n) " -n 1 VAR
    VAR=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]')
    echo
done

# Delete logs for each run
for RUN in ${RUNS}; do
  echo "Deleting logs for run ${RUN}"
  gh api \
    --silent \
    --method DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/${REPOSITORY}/actions/runs/${RUN}/logs" || echo "Failed to delete logs for run ${RUN}"

  # Sleep for 100ms to avoid rate limiting
  sleep 0.1
done

