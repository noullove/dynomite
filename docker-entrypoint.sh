#!/bin/bash

set -e

# shellcheck disable=SC1091
source /etc/profile

# Delete outdated PID file
[[ -e /var/run/redis.pid ]] && rm --force /var/run/redis.pid
[[ -e /var/run/dynomite.pid ]] && rm --force /var/run/dynomite.pid

export TZ=Asia/Seoul

sed -i "s/SERVER_IP/$SERVER_IP/g" /opt/dynomite/conf/dynomite.yml
sed -i "s/SERVER_NAME/$SERVER_NAME/g" /opt/dynomite/conf/dynomite.yml
sed -i "s/SEED_IP/$SEED_IP/g" /opt/dynomite/conf/dynomite.yml
sed -i "s/SEED_NAME/$SEED_NAME/g" /opt/dynomite/conf/dynomite.yml

/usr/local/bin/redis-server /usr/local/etc/redis.conf
/opt/dynomite/sbin/dynomite -c /opt/dynomite/conf/dynomite.yml -d -p /var/run/dynomite.pid -o /var/log/dynomite.log
tail -F /var/log/*.log
