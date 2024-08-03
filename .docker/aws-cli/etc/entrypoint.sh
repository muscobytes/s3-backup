#!/usr/bin/env sh
#set -x

if [ -n "$PERIODIC" ]; then
  case $PERIODIC in
    15min)
      ln -s /backup.sh /etc/periodic/15min/
    ;;
    daily)
      ln -s /backup.sh /etc/periodic/daily/
    ;;
    hourly)
      ln -s /backup.sh /etc/periodic/hourly/
    ;;
    monthly)
      ln -s /backup.sh /etc/periodic/monthly/
    ;;
    weekly)
      ln -s /backup.sh /etc/periodic/weekly/
    ;;
  esac
  /usr/sbin/crond -f
fi
