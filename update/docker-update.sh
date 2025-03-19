#!/usr/bin/env bash
# 0 5 * * * shane bash /home/shane/bin/docker-update.sh docker.flaresolverr >/dev/null 2>&1

DISCORD_WEBHOOK="https://discord.com/api/webhooks/882795463856750694/B9Cc_JOpkfdnPm3I4m8Z0KKSfGVyZtHIDDmf4TMdisKgJ4uX_UWa3qooHVY2yBgTMM2X"
#LOG_FILE="/tmp/update.log"

[[ -z "${DISCORD_WEBHOOK}" ]] && echo "Invalid Configuration" && exit 1
#[[ -z "${LOG_FILE}" ]] && echo "Invalid Configuration" && exit 1

# shellcheck disable=SC2317
function sendDiscord() {
    [[ -z "${1}" ]] && return || MSG="${1}"
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"${MSG}\"}" \
        "${DISCORD_WEBHOOK}"
}

#set -e
#exec > >(tee -a "${LOG_FILE}") 2>&1

SCRIPT="$(basename "${0}")"
echo "Running: ${SCRIPT} - $(date)"

for file in "$@"; do
    echo "Processing: ${file}"
    if [ ! -f "/home/shane/${file}" ];then
        echo "File not found: /home/shane/${file}"
        sendDiscord ":no_entry: **${HOSTNAME}** - \`${SCRIPT}\` - File not found: \`${file}\`"
        continue
    fi

    eval "$(head -n2 "/home/shane/${file}")"
    # shellcheck disable=SC2154
    echo "name: ${_name}"
    # shellcheck disable=SC2154
    echo "image: ${_image}"

    result="$(docker pull "${_image}")"
    echo "result: ${result}"
    if echo "${result}" | grep "Image is up to date";then
        continue
    fi

    echo "---"

    # shellcheck disable=SC1090
    if source "/home/shane/${file}";then
        sendDiscord ":white_check_mark: **${HOSTNAME}** - \`${SCRIPT}\` - Updated: \`${_name}\`"
    else
        sendDiscord ":no_entry: **${HOSTNAME}** - \`${SCRIPT}\` - ERROR Updating: \`${_name}\`"
    fi
done

exit 0
