#!/usr/bin/env bash
# 0 4 * * * shane bash /home/shane/bin/backup-samba.sh >/dev/null 2>&1

DISCORD_WEBHOOK=""

SAMBA_USER=""
SAMBA_PASS=""
SAMBA_HOST=""
SAMBA_PATH="Samba/${HOSTNAME//.*/}"
SAMBA_MAX="10"

BACKUP_DIR="/home/shane"
EXCLUDE_DIRS=(".cache" "esphome/.esphome" "idea" ".local" "motion" "miniconda3" "venv" ".docker" "influxdb/data" "tmp" "temp" "ha/.storage")
BACKUP_NAME="${HOSTNAME//.*/}-$(date "+%y.%m.%d.%H%M.%S").tar.gz"
MOUNT_DIR="/tmp/${SAMBA_HOST}"
LOG_FILE="/tmp/backup.log"

[[ -z "${DISCORD_WEBHOOK}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${SAMBA_USER}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${SAMBA_PASS}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${SAMBA_HOST}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${SAMBA_PATH}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${BACKUP_DIR}" ]] && echo "Invalid Configuration" && exit 1
[[ -z "${BACKUP_NAME}" ]] && echo "Invalid Configuration" && exit 1
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
        sendDiscord ":no_entry: \`${SCRIPT}\`: Backup of \`${BACKUP_DIR}\` on \`${HOSTNAME}\` has FAILED!"
    fi
    if [[ -d "${WORK_DIR}" ]]; then
        echo rm -rf "${WORK_DIR}"
        rm -rf "${WORK_DIR}"
    fi
    sudo umount "${MOUNT_DIR}" > /dev/null || :
    rmdir "${MOUNT_DIR}" > /dev/null || :
    exit "${_ST}"
}

set -e
exec > >(tee -a "${LOG_FILE}") 2>&1

SCRIPT="$(basename "${0}")"
echo "${SCRIPT}: Starting Backup: $(date)"

trap work_dir_trap EXIT HUP INT QUIT PIPE TERM
WORK_DIR=$(mktemp -d)
echo "${SCRIPT}: Working directory: ${WORK_DIR}"
cd "${WORK_DIR}"

mkdir -p "${MOUNT_DIR}"
sudo mount -t cifs "//${SAMBA_HOST}/${SAMBA_PATH}" "${MOUNT_DIR}" \
    -o "username=${SAMBA_USER},password=${SAMBA_PASS},dir_mode=0777,file_mode=0777,rw"
ls -lAh "${MOUNT_DIR}"

for dir in "${EXCLUDE_DIRS[@]}"; do
    exclude_string="${exclude_string} --exclude ${dir}"
done

tar ${exclude_string} -czf "${WORK_DIR}/${BACKUP_NAME}" -C "${BACKUP_DIR}" .
cp "${WORK_DIR}/${BACKUP_NAME}" "${MOUNT_DIR}"
stat "${MOUNT_DIR}/${BACKUP_NAME}"
rm "${WORK_DIR}/${BACKUP_NAME}"

echo "${SCRIPT}: Backup Success!"

if [ -n "${SAMBA_MAX}" ]; then
    echo "Cleaning Up Backups, keeping ${SAMBA_MAX}"
    ((SAMBA_MAX++))
    cd "${MOUNT_DIR}"
    find . -maxdepth 1 -type f -printf '%T+ %p\n' | sort -r | tail -n +"${SAMBA_MAX}" | cut -d' ' -f2 | while read -r file; do
        echo "Removing Old Backup: ${file}"
        rm -f "${file}"
    done
    ls -lAh "${MOUNT_DIR}"
fi

# sendDiscord ":white_check_mark: \`${SCRIPT}\`: Backup of \`${BACKUP_DIR}\` on **${HOSTNAME}** is Successful."
set +e
exit 0
