#!/bin/bash
set -e

WP_PATH="/var/www/html"

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

mkdir -p $WP_PATH
mkdir -p /var/www/.wp-cli/cache

chown -R www-data:www-data /var/www
chmod -R 755 /var/www

echo "Waiting for MariaDB to be ready..."
TIMEOUT=60
count=0
while ! mysql -h"$WP_HOST" -P"$WP_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
    if [ $count -ge $TIMEOUT ]; then
        echo "Error: MariaDB is still unavailable after $TIMEOUT seconds"
        exit 1
    fi
    echo "MariaDB is unavailable: waiting 2 seconds..."
    sleep 2
    count=$((count + 2))
done
echo "MariaDB is ready!"

su www-data -s /bin/bash -c "
    cd $WP_PATH
    if ! wp core is-installed > /dev/null 2>&1; then
        echo 'WordPress not found, installing...'
        wp core download --path=$WP_PATH
        wp core config --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$WP_HOST
        echo 'Installing WP and creating admin user...'
        wp core install --url="https://$DOMAIN_NAME" --title=$DOMAIN_NAME --admin_user=$WP_ADMIN --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email
    fi
    if ! wp user get $WP_USER > /dev/null 2>&1; then
        echo 'Creating second user...'
        wp user create $WP_USER $WP_EMAIL --role=author --user_pass=$WP_PASSWORD
    fi
"

echo "Starting PHP in foreground..."
exec php-fpm8.2 -F



# #!/bin/bash
# set -e

# # Create directories
# echo "Creating PHP directories..."
# mkdir -p /run/php
# mkdir -p /var/run/php

# # Download WordPress if not already present
# if [ ! -f /var/www/html/wp-config.php ] && [ ! -f /var/www/html/index.php ]; then
#     echo "WordPress not found, downloading..."
#     wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
#     tar -xzf /tmp/wordpress.tar.gz -C /tmp/
#     cp -r /tmp/wordpress/* /var/www/html/
#     rm -rf /tmp/wordpress.tar.gz /tmp/wordpress
#     echo "WordPress downloaded and extracted."
# fi

# # Wait for database to be ready
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

# # Set correct permissions
# echo "Setting file permissions..."
# chown -R www-data:www-data /var/www/html
# chmod -R 755 /var/www/html

# # Start PHP-FPM
# echo "Starting PHP-FPM..."
# exec php-fpm8.2 -F