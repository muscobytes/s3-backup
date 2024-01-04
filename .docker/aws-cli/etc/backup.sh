#!/usr/bin/env sh
set -x

TARGET_DIR=/backup
BACKUP_PATH=/opt/${PROJECT_NAME}_$(date +%Y%m%d_%H%I%S).tar.gz

MYSQL_DUMP_DIR=${TARGET_DIR}/mysql
MYSQL_PORT=${MYSQL_PORT:-3306}

POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}

TAR_CHECKPOINT=${TAR_CHECKPOINT:-5000}

S3_ENDPOINT_URL=${S3_ENDPOINT_URL:-https://storage.yandexcloud.net}
S3_PATH=${S3_PATH:-renaissance_backup}
S3_REGION=${S3_REGION:-ru-central1}

[ -z "${PROJECT_NAME}" ] \
    && echo "PROJECT_NAME is not set" && exit 1

[ -z "${AWS_SECRET_ACCESS_KEY}" ] \
    && echo "AWS_SECRET_ACCESS_KEY is not set" && exit 1

[ -z "${AWS_ACCESS_KEY_ID}" ] \
    && echo "AWS_ACCESS_KEY_ID is not set" && exit 1

################################################################################
# MySQL backup
################################################################################
if [ -n "${MYSQL_HOST}" ] \
    && [ -n "${MYSQL_PORT}" ] \
    && [ -n "${MYSQL_USER}" ] \
    && [ -n "${MYSQL_PASSWORD}" ] \
    && [ -n "${MYSQL_DATABASE}" ]
then
    echo "MySQL backup enabled"
    mkdir -p ${TARGET_DIR}/mysql && \
        mysqldump --host ${MYSQL_HOST} \
            --port=${MYSQL_PORT} \
            --user=${MYSQL_USER} \
            --password=${MYSQL_PASSWORD} \
            --databases ${MYSQL_DATABASE} \
            --no-tablespaces \
            > ${TARGET_DIR}/mysql/${MYSQL_DATABASE}.sql
else
    echo "MySQL backup disabled"
fi

################################################################################
# PostgreSQL backup
################################################################################
if [ -n "${POSTGRES_HOST}" ] \
    && [ -n "${POSTGRES_PORT}" ] \
    && [ -n "${POSTGRES_USER}" ] \
    && [ -n "${POSTGRES_PASSWORD}" ] \
    && [ -n "${POSTGRES_DATABASE}" ]
then
    echo "PostreSQL backup enabled"
    echo "${POSTGRES_HOST}:${POSTGRES_PORT}:${POSTGRES_DATABASE}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > ~/.pgpass \
    && chmod 0600 ~/.pgpass \
    && mkdir -p ${TARGET_DIR}/postgres \
    && pg_dump --verbose \
        --file=${TARGET_DIR}/postgres/${POSTGRES_DATABASE}.dump
else
    echo "PostgreSQL backup disabled"
fi

################################################################################
# Archieve and upload to S3
################################################################################
if [ -d "${TARGET_DIR}" ]
then
    echo " > Creating backup"
    tar \
        --totals \
        --checkpoint=${TAR_CHECKPOINT} \
        -czf ${BACKUP_PATH} ${TARGET_DIR} \
    && aws \
        --endpoint-url=${S3_ENDPOINT_URL} \
        --region=${S3_REGION} \
        s3 cp ${BACKUP_PATH} s3://${S3_PATH}/
fi
