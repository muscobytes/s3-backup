#!/usr/bin/env sh
# set -x

BACKUP_DIR=/backup
BACKUP_PATH=${BACKUP_DIR}/${FILENAME}

mkdir -p ${BACKUP_DIR} \
    && tar -czvf ${BACKUP_PATH} ${MEDIA_DIR} \
    && aws \
        --endpoint-url=https://storage.yandexcloud.net \
        --region=ru-central1 \
        s3 cp ${BACKUP_PATH} s3://renaissance-backups/${PROJECT_NAME}
