# S3 Backup

This image can create MySQL/PostgreSQL dumps, archive mounted dir and dumps to tar and upload it to S3-compatible bucket.

## Setup

- `PREFIX` — **Required**, using in tar archive filename and S3 path.

### S3 bucket settings

- `AWS_SECRET_ACCESS_KEY` — **Required.**
- `AWS_ACCESS_KEY_ID` — **Required.**
- `S3_BUCKET` — **Required.**
- `S3_ENDPOINT_URL` — _Optional_, Default value: `https://storage.yandexcloud.net`
- `S3_REGION` — _Optional_, Default value: `ru-central1`
- `S3_PATH` — _Optional_, Default value: `${PROJECT_NAME}`

### MySQL dump options

If required variables are not set MySQL dump creation won't be started with the following notice: `"MySQL backup disabled"`.
- `MYSQL_HOST` — **Required.**
- `MYSQL_USER` — **Required.**
- `MYSQL_PASSWORD` — **Required.**
- `MYSQL_DATABASE` — **Required.**
- `MYSQL_PORT` — _Optional._, MySQL port number, default value: `3306`

### PostgreSQL dump options

- `PGPASSWORD` — **Required.**
- `POSTGRE_USER` — _Optional_, PostgreSQL username, default value: `postgres`
- `POSTGRE_PORT` — _Optional_, PostgreSQL port number, default value: `5432`

## Tar archive creation

- `BACKUP_FILENAME` — _Optional_, tar archive filename, default value: `${PREFIX}_$(date +%Y%m%d_%H%I%S).tar.gz`
- `TAR_CHECKPOINT` — _Optional_, using in the ‘--checkpoint’ option that prints an occasional message as tar reads or writes the archive. It prints a message each 5000 records written. This can be changed by setting up a numeric environment variable `TAR_CHECKPOINT`:<br />
```shell
$ tar -c --checkpoint=1000 /var
  tar: Write checkpoint 1000
  tar: Write checkpoint 2000
  tar: Write checkpoint 3000
```