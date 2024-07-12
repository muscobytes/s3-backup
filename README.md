# S3 Backup

![S3 backup](logo.png)

This image can create MySQL/PostgreSQL dumps, compress mounted dir and dumps into the tar archive and upload it to S3-compatible bucket.

## Cases
- make mysql dump, compress and upload to s3 
- mount folder from side docker volume, create mysql dump, compress target dir and upload to s3
- create mysql & postgre dump, compress, and upload to s3
- mount folder with tar archive and upload it to s3

## Setup
- `PREFIX` — **Required**, using in tar archive filename and S3 path.
- `DATE_FORMAT` — Using in filenames of archive and database dumps.\
_Optional_, default value: `%Y-%m-%d_%H-%M-%S`.
- `TARGET_DIR` — Path to target directory that will be archived.\
_Optional_, default value: `/target`.

### S3 bucket settings
- `AWS_ACCESS_KEY_ID` — **Required.**
- `AWS_SECRET_ACCESS_KEY` — **Required.**
- `S3_BUCKET` — **Required.**
- `S3_ENDPOINT_URL` — _Optional_, Default value: `https://storage.yandexcloud.net`
- `S3_REGION` — _Optional_, Default value: `ru-central1`
- `S3_PATH` — Do not set starting and trailing slashes to the path.\
_Optional_, Default value: `backup`

### MySQL dump options
Variables that marked as `required` are required only if MySQL dump creation is necessary and not required for running this script.

If the required variables are not set, the MySQL dump creation won't start, and the following notice will be displayed: `"MySQL backup disabled"`.
- `MYSQL_HOST` — **Required for creating MySQL dump.**
- `MYSQL_USER` — **Required for creating MySQL dump.**
- `MYSQL_PASSWORD` — **Required for creating MySQL dump.**
- `MYSQL_DATABASE` — **Required for creating MySQL dump.**
- `MYSQL_PORT` — _Optional_, MySQL port number, default value: `3306`

### PostgreSQL dump options
- `PGPASSWORD` — **Required for creating Postgre dump**.
- `POSTGRE_DATABASE` — **Required for creating Postgre dump**.
- `POSTGRE_USER` — _Optional_, Postgre username, default value: `postgres`
- `POSTGRE_PORT` — _Optional_, Postgre port number, default value: `5432`

## Tar archive creation
- `BACKUP_FILENAME` —  Target tar archive filename that should be uploaded to S3 bucket.\
  _Optional_, default value: `${BACKUP_FILENAME_PREFIX}$(date +"${DATE_FORMAT}").tar.gz`.
- `TAR_CHECKPOINT` — Value used in the option ‘--checkpoint’ that prints an occasional message as tar reads or writes the archive. It prints a message each 5000 records written. This can be changed by setting up a numeric environment variable `TAR_CHECKPOINT`:<br>
```shell
$ tar -c --checkpoint=1000 /var
  tar: Write checkpoint 1000
  tar: Write checkpoint 2000
  tar: Write checkpoint 3000
```
_Optional_, default value: `5000`