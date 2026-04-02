 ### Automated Backup & Restore Test

This Bash script is developed to automatically create PostgreSQL database backups, verify their, upload them to cloud storage (AWS S3), and clean up old local copies.

#### Main Features

1. Secure Backup: Uses pg_dump with gzip archiving through a reliable pipeline with set -o pipefail enabled.
2. Automatic Verification (Test Restore): Before uploading to the cloud, the script creates a test database, restores the newly created backup there, and only continues its work if the test is successful.
3. Cloud Synchronization: Successful backups are automatically uploaded to AWS S3 (or any other S3-compatible storage).
4. Local Copy Rotation: Old archives are deleted from the server only if the fresh backup is successfully uploaded to the cloud.

#### Prerequisites

For the script to work correctly, the following must be installed on your server:
**PostgreSQL Client** (pg_dump, psql, gzip).
**AWS CLI** (installed and configured).
Access Configuration
To allow the script to run automatically (for example, via cron) without asking for a password, you need to configure access:
PostgreSQL Access: Create a ~/.pgpass file in the home directory of the user running the script:

```
# Format: hostname:port:database:username:password
*:5432:*:postgres:your_super_secret_password
```

Do not forget to set the correct permissions: `chmod 0600 ~/.pgpass`
AWS S3 Access: Configure the access keys to your bucket:

`aws configure`

#### Configuration

Open the backup.sh script and change the following variables for your project:
```
DB="my_database"               # Name of your main database
USER="postgres"                # DB user
DIR="/backups"                 # Local folder for storing archives
S3="s3://my-backup-bucket/db/" # Path to your AWS S3 bucket
DAYS=7                         # How many days to keep local backups
```
**Usage**
Download the script to your server

Make it executable:
`chmod +x backup.sh`

Run it manually to test:
`./backup.sh`

Automation via Cron
To make backups run automatically every day (for example, at 03:00 AM), add a task to cron:
`crontab -e`

Add the following line:
``0 3 * * * /bin/bash /path/to/your/backup.sh >> /var/log/pg_backup.log 2>&1``

#### Error Handling (Fail-safe)

If pg_dump fails with an error, the corrupted archive is deleted immediately.
If the restore test fails, the script stops working, deletes the archive, and does not upload the broken file to S3, so it won't overwrite good copies.
The test_restore database is deleted automatically in any scenario (success or error).
