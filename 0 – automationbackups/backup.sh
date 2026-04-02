#!/bin/bash
set -e
set -o pipefail

DB="my_database"
USER="postgres"
DIR="/backups"
S3="s3://my-backup-bucket/db/"
DAYS=14

DATE=$(date +"%Y%m%d_%H%M")
FILE="$DIR/$DB-$DATE.sql.gz"
TEST_DB="test_restore"

mkdir -p "$DIR"

echo "Starting backup..."
if pg_dump -U "$USER" "$DB" | gzip > "$FILE"; then
  echo "Backup done: $FILE"
else
  echo "Backup failed!"
  rm -f "$FILE"
  exit 1
fi

echo "Testing restore..."
psql -U "$USER" -c "DROP DATABASE IF EXISTS $TEST_DB;" > /dev/null 2>&1
psql -U "$USER" -c "CREATE DATABASE $TEST_DB;" > /dev/null 2>&1

# Check if restore is successful
if gunzip -c "$FILE" | psql -U "$USER" -d "$TEST_DB" > /dev/null 2>&1; then
  echo "Restore OK"
  
  # Clean up test database
  psql -U "$USER" -c "DROP DATABASE $TEST_DB;" > /dev/null 2>&1
  
  #Upload to S3
  echo "Uploading to S3..."
  if aws s3 cp "$FILE" "$S3"; then
    echo "Uploaded to S3"
    
    find "$DIR" -name "*.sql.gz" -mtime +"$DAYS" -exec rm {} \;
    echo "Cleaned old backups"
  else
    echo "S3 upload failed! Old backups were kept for safety."
    exit 1
  fi
  
else
  echo "Restore failed! Deleting corrupted backup."
  
  psql -U "$USER" -c "DROP DATABASE IF EXISTS $TEST_DB;" > /dev/null 2>&1
  rm -f "$FILE"
  exit 1
fi
