#!/bin/bash -x

#cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bk
#cp /etc/nginx/nginx_waiting.conf /etc/nginx/nginx.conf

## Multistore
export IFS=","
stores=$APPLICATION_STORE_NAMES

for one_store_name in $stores; do
  export LOWER_ONE_STORE="${one_store_name,,}"
  export ONE_STORE=$one_store_name
  j2 /etc/nginx/conf.d/vhost-yves.conf.j2 > /etc/nginx/conf.d/vhost-yves-$LOWER_ONE_STORE.conf
  j2 /etc/nginx/conf.d/vhost-yves-test.conf.j2 > /etc/nginx/conf.d/vhost-yves-test-$LOWER_ONE_STORE.conf
  j2 /etc/nginx/conf.d/vhost-zed.conf.j2 > /etc/nginx/conf.d/vhost-zed-$LOWER_ONE_STORE.conf
  j2 /etc/nginx/conf.d/vhost-zed-test.conf.j2 > /etc/nginx/conf.d/vhost-zed-test-$LOWER_ONE_STORE.conf
  j2 /etc/nginx/conf.d/vhost-glue.conf.j2 > /etc/nginx/conf.d/vhost-glue-$LOWER_ONE_STORE.conf
  j2 /etc/nginx/conf.d/vhost-glue-test.conf.j2 > /etc/nginx/conf.d/vhost-glue-test-$LOWER_ONE_STORE.conf
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

#      # Disable maintenance mode to validate LetsEncrypt certificates
#      test -f /maintenance_on.flag && rm /maintenance_on.flag
#      bash /setup_ssl.sh ${YVES_HOST//www./} $(curl http://checkip.amazonaws.com/ -s) &
#fi
#cp /etc/nginx/nginx.conf.bk /etc/nginx/nginx.conf
killall -9 nginx

chmod 777 -fR /data/shop/development/current/data

supervisorctl restart php-fpm
supervisorctl restart nginx

# Unset maintenance flag
test -f /maintenance_on.flag && rm /maintenance_on.flag

# Call command...
exec $*
