#!/usr/bin/env sh
set -x

BACKUP_DIR=/backup
BACKUP_PATH=${BACKUP_DIR}/${PROJECT_NAME}_$(date +%Y%m%d_%H%I%S).tar.gz

mkdir -p ${BACKUP_DIR} \
    && tar cf - /media | pv -s $(du -sb /media | awk '{print $1}') | gzip > ${BACKUP_PATH} \
    && aws \
        --endpoint-url=https://storage.yandexcloud.net \
        --region=ru-central1 \
        s3 cp ${BACKUP_PATH} s3://renaissance-backups/${PROJECT_NAME}/

# && tar -czf --totals --checkpoint=5000 ${BACKUP_PATH} /media \