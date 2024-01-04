FROM amazon/aws-cli:latest

RUN yum -y install tar xz gzip mysql nc iputils postgresql \
    && yum -y clean all \
    && rm -rf /var/cache

WORKDIR /

COPY .docker/aws-cli/etc/backup.sh /backup.sh

RUN chmod +x /backup.sh
