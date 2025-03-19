#!/usr/bin/env bash

# Delete all releases for a given repository
# Usage: delete-releases.sh <repository>

set -oe pipefail

REPOSITORY=$1

# Validate arguments
if [[ -z "${REPOSITORY}" ]]; then
    echo "Repository is required"
    exit 1
fi

echo "Getting all releases for: ${REPOSITORY}"

_TAGS=$(gh -R "${REPOSITORY}" release list --json tagName --jq '.[].tagName')

echo "Found $(echo "${_TAGS}" | wc -l) releases for: ${REPOSITORY}"

echo -e "WARNING: DELETING ALL RELEASES + TAGS!\n\nRELEASES + TAGS\n"
echo "THIS INCLUDES THE TAG FOR THE RELEASES!"
echo "THIS CAN NOT BE UNDONE!!!!!!!!!!!!!!!!!"

echo "----------"
# shellcheck disable=SC2086
echo ${_TAGS}
echo "----------"

until [[ ${VAR} =~ y|n ]];do
    read -r -p "Proceed? (y/n) " VAR
    VAR=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]')
    echo
done
[[ ${VAR} != "y" ]] && exit 1

for _tag in ${_TAGS}; do
    echo "Deleting release: ${_tag}"
    #gh -R "${REPOSITORY}" release delete "${_tag}" --cleanup-tag &&\
    #    echo "Success. Deleted release: ${_tag}" ||\
    #    echo "FAILED to delete release: ${_tag}"
    sleep 0.1
done

