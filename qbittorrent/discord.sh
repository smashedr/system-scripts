#!/usr/bin/env bash
# /config/discord.sh "%N" "%Z" "%L" "%C" "discord-webhook"

NAME="$1"
SIZE="$(numfmt --to=iec-i --suffix=B --format="%9.2f" "$2")"
CAT="$3"
FILES="$4"
HOOK="$5"

# shellcheck disable=SC2317
function sendDiscord() {
    [[ -z "${1}" ]] && return || MSG="${1}"
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"${MSG}\"}" \
        "${HOOK}"
}

OUTPUT=":file_folder: \`${CAT:-unknown}\` (${FILES}) **${NAME}** ${SIZE}"
echo "OUTPUT: ${OUTPUT}"
sendDiscord "${OUTPUT}"
