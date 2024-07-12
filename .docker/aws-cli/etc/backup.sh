#!/usr/bin/env sh
#set -x

COMPRESS_TARGET_DIR=${COMPRESS_TARGET_DIR:-1}
REMOVE_DATABASE_DUMP_FILES=${REMOVE_DATABASE_DUMP_FILES:-1}
REMOVE_BACKUP_FILE=${REMOVE_BACKUP_FILE:-1}

DATE_FORMAT=${DATE_FORMAT:-%Y-%m-%d_%H-%M-%S}

TARGET_DIR=${TARGET_DIR:-/target}
DATABASE_DUMP_DIR=${TARGET_DIR}/dump

BACKUP_FILENAME=${BACKUP_FILENAME:-${BACKUP_FILENAME_PREFIX}$(date +"${DATE_FORMAT}").tar.gz}
BACKUP_FILE_PATH=${BACKUP_FILE_PATH:-/${BACKUP_FILENAME}}

MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_DUMP_FILE_PATH=${DATABASE_DUMP_DIR}/${MYSQL_DATABASE}_$(date +"${DATE_FORMAT}").sql

POSTGRE_USER=${POSTGRE_USER:-POSTGRE}
POSTGRE_PORT=${POSTGRE_PORT:-5432}
PG_DUMP_FILE_PATH=${DATABASE_DUMP_DIR}/${POSTGRE_DATABASE}_$(date +"${DATE_FORMAT}").dump

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
        --no-tablespaces \
        --databases \
        "${MYSQL_DATABASE}" \
        > "${MYSQL_DUMP_FILE_PATH}"
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
        --file="${PG_DUMP_FILE_PATH}" \
        "${POSTGRE_DATABASE}"
else
    echo "PostgreSQL backup disabled"
fi

################################################################################
# Optionally archive target folder
################################################################################
if [ -d "${TARGET_DIR}" ]; then
    if [ "${COMPRESS_TARGET_DIR}" = 1 ]; then
        echo " > Creating tar archive" \
        && ls -la "${TARGET_DIR}" \
        && tar \
            --totals \
            --checkpoint="${TAR_CHECKPOINT}" \
            -czf "${BACKUP_FILE_PATH}" "${TARGET_DIR}"
    fi

    # Upload backup archive to S3
    aws \
        --endpoint-url="${S3_ENDPOINT_URL}" \
        --region="${S3_REGION}" \
        s3 cp "${BACKUP_FILE_PATH}" "s3://${S3_BUCKET}/${S3_PATH}/"
fi

################################################################################
# Cleanup
################################################################################
if [ "${REMOVE_DATABASE_DUMP_FILES}" = 1 ]; then
  if [ -f "${PG_DUMP_FILE_PATH}" ]; then
    echo "🗑️ Removing ${PG_DUMP_FILE_PATH}"
    rm -f "${PG_DUMP_FILE_PATH}"
  fi

  if [ -f "${MYSQL_DUMP_FILE_PATH}" ]; then
    echo "🗑️ Removing ${MYSQL_DUMP_FILE_PATH}"
    rm -f "${MYSQL_DUMP_FILE_PATH}"
  fi
fi

if [ "${REMOVE_BACKUP_FILE}" = 1 ]; then
  if [ -f "${BACKUP_FILE_PATH}" ]; then
    echo "🗑️ Removing ${BACKUP_FILE_PATH}"
    rm -f "${BACKUP_FILE_PATH}"
  fi
fi