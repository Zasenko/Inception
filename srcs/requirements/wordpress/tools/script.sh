#!/bin/sh
set -e
if [ ! -f wp-config.php ]; then

curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress/* .
rm -rf wordpress latest.tar.gz

wp config create \
  --dbname=$MYSQL_DATABASE \
  --dbuser=$MYSQL_USER \
  --dbpass=$MYSQL_PASSWORD \
  --dbhost=mariadb \
  --allow-root

wp core install \
  --url=$DOMAIN_NAME \
  --title="Inception" \
  --admin_user=$WP_ADMIN \
  --admin_password=$WP_ADMIN_PASSWORD \
  --admin_email=$WP_ADMIN_EMAIL \
  --allow-root

fi

exec "$@"