#!/bin/bash

BACKUPS_DIR="/app/data/backups"
LOG_FILE="/app/data/backups/.restore-log"

mkdir -p "$BACKUPS_DIR"
touch "$LOG_FILE"
mapfile -t restore_logs < "$LOG_FILE"

contains() {
  local element match="$1"
  shift
  for element; do [[ "$element" == "$match" ]] && return 0; done
  return 1
}

for zip_file in "$BACKUPS_DIR"/*.zip; do
    if [ -e "$zip_file" ] && ! contains "$zip_file" "${restore_logs[@]}"; then
        echo "There is a pending backup: $zip_file , so deleting pgdata directory."
        rm -rf /var/lib/postgresql/data/pgdata
    fi
done
