#!/usr/bin/env bash
# 0 3 * * * shane bash /home/shane/bin/backup-influx.sh >/dev/null 2>&1

DISCORD_WEBHOOK=""

export INFLUX_URL="http://localhost:8086"
export INFLUX_ORG=""
export INFLUX_TOKEN=""

BACKUP_NAME="influxdb-$(date "+%y.%m.%d.%H%M.%S").tar.gz"
BACKUP_DIR="/home/shane/backup/influxdb"
LOG_FILE="/tmp/backup.log"

[[ -z "${DISCORD_WEBHOOK}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${INFLUX_URL}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${INFLUX_ORG}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${INFLUX_TOKEN}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${BACKUP_NAME}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${BACKUP_DIR}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${LOG_FILE}" ]] && echo "Invalid Configuration" && exit 1

function sendDiscord() {
    [[ -z "${1}" ]] && return || MSG="${1}"
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"${MSG}\"}" \
        "${DISCORD_WEBHOOK}"
}

function work_dir_trap() {
    _ST="$?"
    if [[ "${_ST}" != "0" ]]; then
        sendDiscord ":no_entry: \`${SCRIPT}\`: Backup of \`influxdb\` on \`${HOSTNAME}\` has FAILED!"
    fi
    if [[ -d "${WORK_DIR}" ]]; then
        echo rm -rf "${WORK_DIR}"
        rm -rf "${WORK_DIR}"
    fi
    exit "${_ST}"
}

set -e
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "BACKUP_NAME: ${BACKUP_NAME}"
echo "BACKUP_DIR: ${BACKUP_DIR}"
echo "BACKUP_NAME: ${BACKUP_NAME}"

SCRIPT="$(basename "${0}")"
echo "${SCRIPT}: Starting Backup: $(date)"

trap work_dir_trap EXIT HUP INT QUIT PIPE TERM
WORK_DIR=$(mktemp -d)
echo "${SCRIPT}: Working directory: ${WORK_DIR}"
cd "${WORK_DIR}"

if [[ -d "${BACKUP_DIR}" ]]; then
    echo rm -rf "${BACKUP_DIR}"
    rm -rf "${BACKUP_DIR}"
fi
mkdir -p "${BACKUP_DIR}"

influx backup "${WORK_DIR}"

tar -czf "${BACKUP_DIR}/${BACKUP_NAME}" -C "${WORK_DIR}" .

echo "${SCRIPT}: Backup Success!"
# sendDiscord ":white_check_mark: \`${SCRIPT}\`: Backup of \`${BACKUP_DIR}\` on **${HOSTNAME}** is Successful."
set +e
exit 0
