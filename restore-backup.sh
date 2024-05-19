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
        echo "Restoring backup: $zip_file ..."
        unzip_dir="${zip_file%.zip}"
        unzip "$zip_file" -d "$BACKUPS_DIR" > /dev/null 2>&1
        ./bin/datomic restore-db "file:$unzip_dir" "datomic:sql://?jdbc:postgresql://localhost:5432/$POSTGRES_DB?user=datomic&password=$DATOMIC_STORAGE_DATOMIC_PASSWORD"
        if [ $? -eq 0 ]; then
            echo "$zip_file" >> "$LOG_FILE"
            echo "Successfully restored: $zip_file"
        else
            echo "Failed to restore: $zip_file"
        fi
        rm -rf "$unzip_dir"
    fi
done
