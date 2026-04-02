#!/bin/bash
DB_NAME="your_db_name"
DB_USER="your_db_user"
BACKUP_DIR="/home/user/backups"
S3_BUCKET="s3://your-bucket-name/database"
RETENTION_DAYS=14 

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
FILENAME="${DB_NAME}_${TIMESTAMP}.sql.gz"
FILEPATH="${BACKUP_DIR}/${FILENAME}"

mkdir -p "$BACKUP_DIR"

echo "[$TIMESTAMP] Dump creation for $DB_NAME"

pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$FILEPATH"

if [ $? -eq 0 ]; then
    echo "Dump successfuly created: $FILENAME"
else
    echo "Dump failed"
    exit 1
fi

echo "Sending to S3"
aws s3 cp "$FILEPATH" "$S3_BUCKET/"

if [ $? -eq 0 ]; then
    echo "Successfuly sent to S3"
else
    echo "Sending to S3 Failed"
fi

echo "Cleaning backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

echo "Finished!"
