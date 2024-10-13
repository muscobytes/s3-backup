FROM alpine:3.20

WORKDIR /

COPY .docker/aws-cli/etc/backup.sh /backup.sh
COPY .docker/aws-cli/etc/entrypoint.sh /entrypoint.sh

RUN chmod +x /backup.sh \
    && chmod +x /entrypoint.sh \
    && apk update \
    && apk add tar xz gzip mysql-client mariadb-connector-c netcat-openbsd iputils postgresql aws-cli

CMD ["/entrypoint.sh"]
