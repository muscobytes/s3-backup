# Renneisance Backup

This image can create MySQL/Pogres dumps, archive mounted dir and dumps to tar and upload it to S3-compatible bucket.

## Setup

### PROJECT_NAME

**Required.**

Used in tar archive filename and S3 path.

## S3 bucket settings

### AWS_SECRET_ACCESS_KEY

**Required.**

### AWS_ACCESS_KEY_ID

**Required.**

### S3_BUCKET

**Required.**

### S3_ENDPOINT_URL

_Optional._

Default value: `https://storage.yandexcloud.net`

### S3_REGION

_Optional._

Default value: `ru-central1`

### S3_PATH

_Optional._

Default value: `${PROJECT_NAME}`

## MySQL dump options

If required variables are not set MySQL dump creation won't be started with the following notice: `"MySQL backup disabled"`.

### MYSQL_HOST

**Required.**

### MYSQL_USER

**Required.**

### MYSQL_PASSWORD

**Required.**

### MYSQL_DATABASE

**Required.**

### MYSQL_PORT

_Optional._

MySQL port number, default value: `3306`

## Postgres dump options

### POSTGRES_USER

_Optional._

Postgres username, default value: `postgres`

### POSTGRES_PORT

_Optional._

Portgres port number, default value: `5432`

## Tar archive creation

### BACKUP_FILENAME

_Optional._

Tar archive filename, deafult value: `${PROJECT_NAME}_$(date +%Y%m%d_%H%I%S).tar.gz`

### TAR_CHECKPOINT

_Optional._

Used in the ‘--checkpoint’ option that prints an occasional message as tar reads or writes the archive. It prints a message each 5000 records written. This can be changed by setting up a numeric envirponment variable `TAR_CHECKPOINT`:

> $ tar -c --checkpoint=1000 /var
> tar: Write checkpoint 1000
> tar: Write checkpoint 2000
> tar: Write checkpoint 3000
