#!/bin/bash


HOST=${DATABASE_HOST}
PORT=${DATABASE_PORT}
USER=${DATABASE_USER}
PASSWORD=${DATABASE_PASSWORD}
DATABASE=${DATABASE_NAME}
BACKUP_DIR=/root/backup
LOG_FILE="/root/log/backup.log"


DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/${DATABASE}_${DATE}.sql"


check_mysql_connection() {
    echo "🔄 Checking MySQL connection to $HOST on port $PORT..."
    mariadb-admin --ssl-verify-server-cert=false -u"$USER" -p"$PASSWORD" -h"$HOST" -P"$PORT" ping > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ MySQL is down or cannot be reached on $HOST:$PORT. Exiting..."
        echo "$(date +"%Y-%m-%d %H:%M:%S") - MySQL connection failed" >> $LOG_FILE
        exit 1
    fi
}




START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "🔄 [$START_TIME] Starting backup of database '$DATABASE' from host '$HOST' on port '$PORT'..."



check_mysql_connection


mkdir -p "$BACKUP_DIR"


echo "🔄 [$START_TIME] Executing mariadb-dump command..."
mariadb-dump --ssl-verify-server-cert=false -u "$USER" -p"$PASSWORD" -h "$HOST" -P "$PORT" "$DATABASE" > "$BACKUP_FILE"


if [ $? -eq 0 ]; then
    END_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    echo "✅ [$END_TIME] Backup completed successfully: $BACKUP_FILE"
else
    END_TIME=$(date +"%Y-%m-%d %H:%M:%S")чё
    echo "❌ [$END_TIME] Backup failed! Removing incomplete backup file: $BACKUP_FILE"
    rm -f "$BACKUP_FILE"
fi


if [ -f "$BACKUP_FILE" ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "📦 [$END_TIME] Backup file size: $FILE_SIZE"
fi


echo "$START_TIME - Backup of database '$DATABASE' (host: $HOST, port: $PORT) started. Backup file: $BACKUP_FILE" >> $LOG_FILE
if [ $? -eq 0 ]; then
    echo "$END_TIME -✅ Backup completed: $BACKUP_FILE" >> $LOG_FILE
else
    echo "$END_TIME -❌ Backup failed: $BACKUP_FILE" >> $LOG_FILE
fi
