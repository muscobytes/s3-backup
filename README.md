# S3 Backup

![S3 backup](logo.png)

This image can create MySQL/PostgreSQL dumps, compress mounted directory and SQL dumps into the tar archive and then upload it to S3-compatible bucket.

## Setup
- Install Docker
- Pull latest version of "S3 Backup" image: \
```shell
docker pull ghcr.io/muscobytes/s3-backup:latest
```

## Examples
### Recursively upload target folder to S3 bucket
In this example presents the configuration required to recursively upload the contents target folder to an S3 bucket.
```shell
docker run --rm -ti \
  -v "/backup:/target" \
  -e AWS_ACCESS_KEY_ID=ASIAY34FZKBOKMUTVV7A \
  -e AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCEXAMPLEKEY \
  -e S3_BUCKET=my-bucket-name \
  -e S3_PATH=path \
  -e COMPRESS_TARGET_DIR=0 \
  ghcr.io/muscobytes/s3-backup:latest \
  /backup.sh
```

- make mysql dump, compress and upload to s3 
- mount folder from side docker volume, create mysql dump, compress target dir and upload to s3
- create mysql & postgre dump, compress, and upload to s3
- mount folder with tar archive and upload it to s3

## Environment variables
### General
- `TARGET_DIR` — _Optional_. Path to target directory that will be archived. Default value: `/target`.
### Tar archive
- `BACKUP_FILENAME_PREFIX` — _Optional_. Prefix for the tar archive filename, applies only when `COMPRESS_TARGET_DIR=1`. Default value: `` (empty).
- `DATE_FORMAT` — _Optional_. Will be used in filenames of archive and database dumps. Applies only when `COMPRESS_TARGET_DIR=1`. Default value: `%Y-%m-%d_%H-%M-%S`.
- `BACKUP_DIR` — _Optional_. Default value: `/backup`.
- `BACKUP_FILENAME` — _Optional_. Tar archive filename that should be uploaded to the S3 bucket. _Optional_. Default value: `${BACKUP_FILENAME_PREFIX}$(date +"${DATE_FORMAT}").tar.gz`.
### Cron
- `PERIODIC` — _Optional_. The period after which cron should run the script. Possible values: `15min`, `hourly`, `daily`, `weekly`, `monthly`. Default value: `` (empty, cron will be disabled). 
### Lifecycle
- `COMPRESS_TARGET_DIR` — _Optional_. When the value is equal to `1` the backup script will create a gzipped tar archive, when the value is equal to `0` the backup script will recursively copy the target directory to the S3 bucket. Default value: `1`. 
- `REMOVE_DATABASE_DUMP_FILES` — _Optional_. When the value is equal to `1`the backup script will remove created database dump files after uploading to S3 bucket will be finishes, if the value is `0` then the dump files will remain intact. Default value: `1`.  
- `REMOVE_BACKUP_FILE` — _Optional_. When the value is equal to `1` the backup script will remove created gzipped tar archive after it finishes uploading it to S3 bucket, otherwise it will leave the backup file intact. Applies only when `COMPRESS_TARGET_DIR=1`. Default value: `1`.
### S3 bucket settings
- `AWS_ACCESS_KEY_ID` — **Required.** 
- `AWS_SECRET_ACCESS_KEY` — **Required.**
- `S3_BUCKET` — **Required.**
- `S3_ENDPOINT_URL` — _Optional_, Default value: `https://storage.yandexcloud.net`
- `S3_REGION` — _Optional_, Default value: `ru-central1`
- `S3_PATH` — S3 path is where to upload the target directory or created tar archive. Do not set starting and trailing slashes to this path. _Optional_, Default value: `backup`
### MySQL dump options
Variables that are marked as `required` are required only if MySQL dump creation is necessary and not required for running this script. If the required variables are not set, the MySQL dump creation won't start, and the following notice will be displayed: `"MySQL backup disabled"`.
- `MYSQL_HOST` — **Required for creating MySQL dump.**
- `MYSQL_USER` — **Required for creating MySQL dump.**
- `MYSQL_PASSWORD` — **Required for creating MySQL dump.**
- `MYSQL_DATABASE` — **Required for creating MySQL dump.**
- `MYSQL_PORT` — _Optional_, MySQL port number, default value: `3306`
### PostgreSQL dump options
Variables that are marked as `required` are required only if PostgreSQL dump creation is necessary and not required for running this script. If the required variables are not set, the PostgreSQL dump creation won't start, and the following notice will be displayed: `"PostgreSQL backup disabled"`.
- `PGPASSWORD` — **Required for creating Postgre dump**.
- `POSTGRE_DATABASE` — **Required for creating Postgre dump**.
- `POSTGRE_USER` — _Optional_, Postgre username, default value: `postgres`
- `POSTGRE_PORT` — _Optional_, Postgre port number, default value: `5432`
