#!/usr/bin/env sh
set -x

DATE_FORMAT=${DATE_FORMAT:-%Y-%m-%d_%H-%M-%S}
TARGET_DIR=${TARGET_DIR:-/target}
DATABASE_DUMP_DIR=${TARGET_DIR}/dump

if [ -z "${BACKUP_FILENAME_PREFIX}" ]; then
    BACKUP_FILENAME_PREFIX=${BACKUP_FILENAME_PREFIX:-}
fi
BACKUP_FILENAME=${BACKUP_FILENAME:-${BACKUP_FILENAME_PREFIX}$(date +"${DATE_FORMAT}").tar.gz}
BACKUP_PATH=${BACKUP_PATH:-/opt/${BACKUP_FILENAME}}

MYSQL_PORT=${MYSQL_PORT:-3306}

POSTGRE_USER=${POSTGRE_USER:-POSTGRE}
POSTGRE_PORT=${POSTGRE_PORT:-5432}

TAR_CHECKPOINT=${TAR_CHECKPOINT:-5000}

S3_ENDPOINT_URL=${S3_ENDPOINT_URL:-https://storage.yandexcloud.net}
S3_PATH=${S3_PATH:-backup}
S3_REGION=${S3_REGION:-ru-central1}

[ -z "${AWS_SECRET_ACCESS_KEY}" ] \
    && echo "AWS_SECRET_ACCESS_KEY is not set" && exit 101

[ -z "${AWS_ACCESS_KEY_ID}" ] \
    && echo "AWS_ACCESS_KEY_ID is not set" && exit 102

[ -z "${S3_BUCKET}" ] \
    && echo "S3_BUCKET is not set" && exit 103

if [ ! -d "${DATABASE_DUMP_DIR}" ]; then
  mkdir --parent "${DATABASE_DUMP_DIR}"
fi

################################################################################
# MySQL backup
################################################################################
if [ -n "${MYSQL_HOST}" ] \
    && [ -n "${MYSQL_USER}" ] \
    && [ -n "${MYSQL_PASSWORD}" ] \
    && [ -n "${MYSQL_DATABASE}" ]
then
    echo "MySQL backup enabled" \
    && mysqldump \
        --host="${MYSQL_HOST}" \
        --port="${MYSQL_PORT}" \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --databases="${MYSQL_DATABASE}" \
        --no-tablespaces \
        > "${DATABASE_DUMP_DIR}/${MYSQL_DATABASE}_$(date +"${DATE_FORMAT}").sql"
else
    echo "MySQL backup disabled"
fi

################################################################################
# PostgreSQL backup
################################################################################
if [ -n "${POSTGRE_HOST}" ] \
    && [ -n "${PGPASSWORD}" ] \
    && [ -n "${POSTGRE_DATABASE}" ]
then
    echo "PostgreSQL backup enabled" \
    && pg_dump \
        --host="${POSTGRE_HOST}" \
        --port="${POSTGRE_PORT}" \
        --username="${POSTGRE_USER}" \
        --format=plain \
        --verbose \
        --file="${DATABASE_DUMP_DIR}/${POSTGRE_DATABASE}_$(date +"${DATE_FORMAT}").dump" \
        "${POSTGRE_DATABASE}"
else
    echo "PostgreSQL backup disabled"
fi

################################################################################
# Optionally archive target folder
################################################################################
if [ -d "${TARGET_DIR}" ]; then
    ls -la "${TARGET_DIR}"
    if [ -z "${DO_NOT_COMPRESS}" ]; then
        echo " > Creating tar archive" \
        && ls -la "${TARGET_DIR}" \
        && tar \
            --totals \
            --checkpoint="${TAR_CHECKPOINT}" \
            -czf "${BACKUP_PATH}" "${TARGET_DIR}"
    fi

    # Upload backup archive to S3
    aws \
        --endpoint-url="${S3_ENDPOINT_URL}" \
        --region="${S3_REGION}" \
        s3 cp "${BACKUP_PATH}" "s3://${S3_BUCKET}/${S3_PATH}/"
fi
