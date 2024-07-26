#!/usr/bin/env sh
set -x

COMPRESS_TARGET_DIR=${COMPRESS_TARGET_DIR:-1}
REMOVE_DATABASE_DUMP_FILES=${REMOVE_DATABASE_DUMP_FILES:-1}
REMOVE_BACKUP_FILE=${REMOVE_BACKUP_FILE:-1}
UPLOAD_TARGET_DIR=${UPLOAD_TARGET_DIR:-0}

DATE_FORMAT=${DATE_FORMAT:-%Y-%m-%d_%H-%M-%S}

TARGET_DIR=${TARGET_DIR:-/target}
DATABASE_DUMP_DIR=${TARGET_DIR}/dump

if [ -n "${BACKUP_FILENAME_PREFIX}" ]; then
  BACKUP_FILENAME_PREFIX=${BACKUP_FILENAME_PREFIX}_
fi

BACKUP_DIR=${BACKUP_DIR:-/backup}

BACKUP_FILENAME=${BACKUP_FILENAME:-${BACKUP_FILENAME_PREFIX}$(date +"${DATE_FORMAT}").tar.gz}
BACKUP_FILE_PATH=${BACKUP_FILE_PATH:-${BACKUP_DIR}/${BACKUP_FILENAME}}

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
    && echo " ⛔ AWS_SECRET_ACCESS_KEY is not set" && exit 101

[ -z "${AWS_ACCESS_KEY_ID}" ] \
    && echo " ⛔ AWS_ACCESS_KEY_ID is not set" && exit 102

[ -z "${S3_BUCKET}" ] \
    && echo " ⛔ S3_BUCKET is not set" && exit 103

if [ ! -d "${BACKUP_DIR}" ]; then
    mkdir --parent "${BACKUP_DIR}"
fi

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
    echo " 💚 MySQL backup enabled, dumping to ${MYSQL_DUMP_FILE_PATH}" \
    && mysqldump \
        --host="${MYSQL_HOST}" \
        --port="${MYSQL_PORT}" \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --no-tablespaces \
        --databases \
        "${MYSQL_DATABASE}" \
        > "${MYSQL_DUMP_FILE_PATH}" \
    && export MYSQL_DUMP_EXECUTES_SUCCESSFULLY=1
    [ -z "${MYSQL_DUMP_EXECUTES_SUCCESSFULLY}" ] && echo " ⛔ Error while creating MySQL dump." && exit 201
else
    echo " ❣️ MySQL backup disabled"
fi

################################################################################
# PostgreSQL backup
################################################################################

if [ -n "${POSTGRE_HOST}" ] \
    && [ -n "${PGPASSWORD}" ] \
    && [ -n "${POSTGRE_DATABASE}" ]
then
    echo " 💚 PostgreSQL backup enabled, dumping to ${PG_DUMP_FILE_PATH}" \
    && pg_dump \
        --host="${POSTGRE_HOST}" \
        --port="${POSTGRE_PORT}" \
        --username="${POSTGRE_USER}" \
        --format=plain \
        --verbose \
        --file="${PG_DUMP_FILE_PATH}" \
        "${POSTGRE_DATABASE}" \
    && export POSTGRE_DUMP_EXECUTES_SUCCESSFULLY=1
    [ -z "${POSTGRE_DUMP_EXECUTES_SUCCESSFULLY}" ] && echo " ⛔ Error while creating PostgreSQL dump." && exit 202
else
    echo " ❣️ PostgreSQL backup disabled"
fi

################################################################################
# Optionally archive target folder
################################################################################
if [ -d "${TARGET_DIR}" ]; then
    if [ "${COMPRESS_TARGET_DIR}" = 1 ]; then
        echo " 🗃️ Creating tar archive" \
        && ls -la "${TARGET_DIR}" \
        && tar \
            --totals \
            --checkpoint="${TAR_CHECKPOINT}" \
            -czf "${BACKUP_FILE_PATH}" "${TARGET_DIR}"
    fi

    if [ "${UPLOAD_TARGET_DIR}" = 1 ]; then
        UPLOAD_DIR=${TARGET_DIR}
    else
        UPLOAD_DIR=${BACKUP_FILE_PATH}
    fi
    # Upload backup archive to S3
    aws \
        --endpoint-url="${S3_ENDPOINT_URL}" \
        --region="${S3_REGION}" \
        s3 cp "${UPLOAD_DIR}" "s3://${S3_BUCKET}/${S3_PATH}/" --recursive \
    && export UPLOAD_TO_S3_FINISHED_SUCCESSFULLY=1
    [ -z "${UPLOAD_TO_S3_FINISHED_SUCCESSFULLY}" ] && echo "  ⛔ Error while uploading file to S3" && exit 203
fi

################################################################################
# Cleanup
################################################################################
if [ "${REMOVE_DATABASE_DUMP_FILES}" = 1 ]; then
  if [ -f "${PG_DUMP_FILE_PATH}" ]; then
    echo " 🗑️ Removing ${PG_DUMP_FILE_PATH}"
    rm -f "${PG_DUMP_FILE_PATH}"
  fi

  if [ -f "${MYSQL_DUMP_FILE_PATH}" ]; then
    echo " 🗑️ Removing ${MYSQL_DUMP_FILE_PATH}"
    rm -f "${MYSQL_DUMP_FILE_PATH}"
  fi
fi

if [ "${REMOVE_BACKUP_FILE}" = 1 ] && [ -n "${UPLOAD_TO_S3_FINISHED_SUCCESSFULLY}" ]; then
  if [ -f "${BACKUP_FILE_PATH}" ]; then
    echo " 🗑️ Removing ${BACKUP_FILE_PATH}"
    rm -f "${BACKUP_FILE_PATH}"
  fi
fi
