#!/usr/bin/env bash

# USE WITH CAUTION!
# This script assumes that it is being used by a
# systemd one-shot service that sets its working 
# directory into the directory with the files that
# are being backed up.
# This is initally being created to store backups created
# by the services.postgresqlBackup nixos module in r2

set -eo pipefail

DEBUG=${DEBUG}
EXTRA_ARGS=('--retries' '5')

[[ "${DEBUG}" == true ]] && {
  EXTRA_ARGS+=( '-vvv' )
  set -x
};

RCLONE_CONFIG=${RCLONE_CONFIG:-"/root/.config/rclone/rclone.conf"}
R2_RCLONE_PROFILE=${R2_RCLONE_PROFILE:?required}
R2_BUCKET=${R2_BUCKET:?required}

DATE=$(date -d "today" +"%Y%m%d%H%M")

BACKUPS_DIR=${BACKUPS_DIR}
BACKUP_FILE=${BACKUP_FILE:-"all.sql.gz"}

BACKUP_PATH="${BACKUPS_DIR}/${BACKUP_FILE}"

rclone copyto \
  "${BACKUP_PATH}" \
  "${R2_RCLONE_PROFILE}:${R2_BUCKET}/${DATE}-${BACKUP_FILE}" "${EXTRA_ARGS[@]}"


rclone copyto \
  "${BACKUP_PATH}" \
  "${R2_RCLONE_PROFILE}:${R2_BUCKET}/latest."${BACKUP_FILE#*.}"" "${EXTRA_ARGS[@]}"
