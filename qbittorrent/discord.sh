#!/usr/bin/env bash
# /config/discord.sh "%N" "%L" "%Z" "%C" "discord-webhook"

NAME="${1}"
CAT="${2}"
SIZE="$(numfmt --to=iec-i --suffix=B --format="%9.2f" "${3}")"
[[ "${4}" == "-1" ]] && FILES="" || FILES="(${4})"
HOOK="${5}"

# shellcheck disable=SC2317
function sendDiscord() {
    [[ -z "${1}" ]] && return || MSG="${1}"
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"${MSG}\"}" \
        "${HOOK}"
}

#set -ex
#LOG_FILE="/config/discord.log"
#exec > >(tee -a "${LOG_FILE}") 2>&1
#echo "debug: $*"

OUTPUT=":file_folder: \`${CAT:-unknown}\` **${NAME}** ${FILES} ${SIZE}"
sendDiscord "${OUTPUT}"
