FROM alpine:3.20

WORKDIR /

COPY .docker/aws-cli/etc/backup.sh /backup.sh

RUN chmod +x /backup.sh \
    && ln -s /backup.sh /etc/periodic/monthly/ \
    && apk update \
    && apk add tar xz gzip mysql-client netcat-openbsd iputils postgresql aws-cli

CMD ["crond", "-f"]
