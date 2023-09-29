FROM amazon/aws-cli:latest

COPY .docker/aws-cli/etc/backup.sh /backup.sh

RUN yum -y install tar xz gzip mysql pv \
    && yum -y clean all \
    && rm -rf /var/cache \
    && chmod +x /backup.sh

ENTRYPOINT [ "/backup.sh" ]
