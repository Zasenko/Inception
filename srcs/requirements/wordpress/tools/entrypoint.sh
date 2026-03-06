#!/bin/bash
set -e

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

mkdir -p /var/www/html
mkdir -p /var/www/.wp-cli/cache

chown -R www-data:www-data /var/www
chmod -R 755 /var/www

echo "Waiting for MariaDB..."
# echo "Waiting for database connection..."
# for i in {1..30}; do
#     if mysql -h"${WP_HOST}" -P"${WP_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1" >/dev/null 2>&1; then
#         echo "Database connection successful!"
#         break
#     fi
#     if [ $i -eq 30 ]; then
#         echo "ERROR: Could not connect to database after 30 attempts"
#         echo "Host: ${WP_HOST}"
#         echo "User: ${MYSQL_USER}"
#         exit 1
#     fi
#     echo "Waiting for database... ($i/30)"
#     sleep 2
# done
TIMEOUT=60
COUNT=0
while ! mysql --host="$WP_HOST" --port="$WP_PORT" --user="$WP_USER" --password="$(cat "$WP_PASSWORD")" -e "SELECT 1;" >/dev/null 2>&1; do
    if [ $COUNT -ge $TIMEOUT ]; then
        echo "Error: MariaDB is still unavailable after $TIMEOUT seconds"
        exit 1
    fi
    echo "MariaDB is unavailable: waiting 2 seconds..."
    sleep 2
    COUNT=$((COUNT + 2))
done
echo "MariaDB is ready!"

su www-data -s /bin/bash -c "
    cd /var/www/html
    if ! wp core is-installed > /dev/null 2>&1; then
        echo 'WordPress not found, installing...'
        wp core download --path=/var/www/html

        wp core config --dbname=$MYSQL_DATABASE --dbuser=$WP_USER --dbpass="$(cat "$WP_PASSWORD")" --dbhost=$WP_HOST

        echo 'Installing WP and creating admin user...'
        
        wp core install --url="https://$DOMAIN_NAME" --title="$DOMAIN_NAME" --admin_user="$WP_USER" --admin_password="$(cat "$WP_PASSWORD")" --admin_email="$WP_ADMIN_EMAIL" --skip-email
    fi
    if ! wp user get editor > /dev/null 2>&1; then
        echo 'Creating second user...'
        wp user create $WP_AUTOR $WP_AUTOR_EMAIL --role=author --user_pass="$(cat "$WP_PASSWORD")"
    fi
"

echo "Starting PHP in foreground..."
exec php-fpm8.2 -F
