#!/bin/bash -x

#cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
#cp /etc/nginx/nginx_waiting.conf /etc/nginx/nginx.conf

## Multistore
export IFS=","
yves_hosts=$YVES_HOST
for one_yves_host in $yves_hosts; do
  export ONE_YVES_HOST=$one_yves_host
  j2 /etc/nginx/conf.d/vhost-yves.conf.j2 > /etc/nginx/conf.d/vhost-yves-$ONE_YVES_HOST.conf
done

zed_hosts=$ZED_HOST
for one_zed_host in $zed_hosts; do
  export ONE_ZED_HOST=$one_zed_host
  j2 /etc/nginx/conf.d/vhost-zed.conf.j2 > /etc/nginx/conf.d/vhost-zed-$ONE_ZED_HOST.conf
  echo "127.0.0.1	$ONE_ZED_HOST" >> /etc/hosts
done

glue_hosts=$GLUE_HOST
for one_glue_host in $glue_hosts; do
  export ONE_GLUE_HOST=$one_glue_host
  j2 /etc/nginx/conf.d/vhost-glue.conf.j2 > /etc/nginx/conf.d/vhost-glue-$ONE_GLUE_HOST.conf
done

/usr/sbin/nginx -g 'daemon on;' &

# Enable maintenance mode
touch /maintenance_on.flag

# Enable PGPASSWORD for non-interactive working with PostgreSQL if PGPASSWORD is not set
export PGPASSWORD=$POSTGRES_PASSWORD
# Waiting for PostgreSQL database starting
until psql -h $POSTGRES_HOST -p "$POSTGRES_PORT" -U "$POSTGRES_USER" $POSTGRES_DATABASE -c '\l'; do
  echo "Waiting for PostgreSQL..."
  sleep 3
done
echo "PostgreSQL is available now. Good."

# Waiting for the Elasticsearch starting
until curl -s "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT" > /dev/null; do
  echo "Waiting for Elasticsearch..."
  sleep 3
done
echo "Elasticsearch is available now. Good."

# Waiting for the RabbitMQ starting
until curl -s "$RABBITMQ_HOST:$RABBITMQ_API_PORT" > /dev/null; do
  echo "Waiting for RabbitMQ..."
  sleep 3
done
echo "RabbitMQ is available now. Good."

# Become more verbose
set -xe

# Configure PHP
j2 /usr/local/etc/php/php.ini.j2 > /usr/local/etc/php/php.ini

chown -R 1000:1000 /data/

#      # Disable maintenance mode to validate LetsEncrypt certificates
#      test -f /maintenance_on.flag && rm /maintenance_on.flag
#      bash /setup_ssl.sh ${YVES_HOST//www./} $(curl http://checkip.amazonaws.com/ -s) &
#fi
#cp /etc/nginx/nginx.conf.bk /etc/nginx/nginx.conf
killall -9 nginx

supervisorctl restart php-fpm
supervisorctl restart nginx

# Unset maintenance flag
test -f /maintenance_on.flag && rm /maintenance_on.flag

# Call command...
exec $*
