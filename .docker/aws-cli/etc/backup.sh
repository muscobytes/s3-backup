#!/usr/bin/env sh
set -x

BACKUP_DIR=/backup
BACKUP_PATH=/opt/${PROJECT_NAME}_$(date +%Y%m%d_%H%I%S).tar.gz

mkdir -p ${BACKUP_DIR}/sql \
    && mysqldump --host ${MYSQL_HOST} \
        --port=${MYSQL_PORT} \
        --user=${MYSQL_USER} \
        --password=${MYSQL_PASSWORD} \
        --databases ${MYSQL_DATABASE} \
        --no-tablespaces \
        > ${BACKUP_DIR}/sql/${MYSQL_DATABASE}.sql \
    && tar -czf --totals --checkpoint=5000 ${BACKUP_PATH} ${BACKUP_DIR} \
    && aws \
        --endpoint-url=https://storage.yandexcloud.net \
        --region=ru-central1 \
        s3 cp ${BACKUP_PATH} s3://renaissance-backups/${PROJECT_NAME}/
