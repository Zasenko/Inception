#!/bin/bash

WP_PATH="/var/www/html"

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
mkdir -p $WP_PATH
chown -R www-data:www-data $WP_PATH
cd $WP_PATH

su www-data -s /bin/bash -c "
    cd $WP_PATH
    if [ ! -f wp-config.php ]; then
        echo 'WordPress not found, installing...'
        wp core download
        wp core config --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$WP_HOST
        wp core install --url=$DOMAIN_NAME --title=$DOMAIN_NAME --admin_user=$WP_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL
        wp user create $WP_USER $WP_EMAIL --role=author --user_pass=$WP_PASSWORD
    fi
"

exec php-fpm8.2 -F



# #!/bin/bash
# set -e

# WP_PATH="/var/www/html"

# mkdir -p $WP_PATH

# chown -R www-data:www-data $WP_PATH
# echo "WP_HOST: $WP_HOST"
# echo "WP_NAME: $WP_NAME" 
# echo "WP_USER: $WP_USER"
# echo "WP_PORT: $WP_PORT"
# echo "MYSQL_PASSWORD: $MYSQL_PASSWORD" 
# echo "MYSQL_DATABASE: $MYSQL_DATABASE"
# echo "MYSQL_USER: $MYSQL_USER"
# echo "WP_PASSWORD: $WP_PASSWORD"
# echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
# echo "DOMAIN_NAME: $DOMAIN_NAME"

# echo "Waiting for database connection... 1"
# timeout=60
# count=0
# until mysql -h ${WP_HOST} -P ${WP_PORT} -u ${WP_USER} -p${WP_PASSWORD} -e "SELECT 1" >/dev/null 2>&1; do
#     echo "Waiting for database connection.. . 1"
#     sleep 2
#     count=$((count+1))
#     if [ $count -ge $timeout ]; then
#             echo "Error: MariaDB failed to start 1" >&2
#             exit 1
#     fi

# done
# echo "Database connected! 1"

# echo "---- MariaDB is ready ----"

# cd $WP_PATH

# # Устанавливаем WordPress ТОЛЬКО если его нет
# if [ ! -f "wp-config.php" ]; then
#     echo "---- Installing WordPress ----"

#     if ! command -v wp &> /dev/null
#     then
#         echo "wp command not found"
#         exit 1
#     fi

#     wp core download --allow-root

#     if [ $? -ne 0 ]; then
#         echo "Error downloading WordPress"
#         exit 1
#     fi

#     wp config create \
#         --dbname="$MYSQL_DATABASE" \
#         --dbuser="$MYSQL_USER" \
#         --dbpass="$MYSQL_PASSWORD" \
#         --dbhost="$WP_HOST" \
#         --allow-root

#     if [ $? -ne 0 ]; then
#         echo "Error creating wp-config.php"
#         exit 1
#     fi

#     wp core install \
#         --url="$DOMAIN_NAME" \
#         --title="Inception" \
#         --admin_user="$WP_ADMIN" \
#         --admin_password="$WP_ADMIN_PASSWORD" \
#         --admin_email="$WP_ADMIN_EMAIL" \
#         --skip-email \
#         --allow-root

#     if [ $? -ne 0 ]; then
#         echo "Error installing WordPress"
#         exit 1
#     fi

#     wp user create \
#         "$WP_USER" "$WP_USER_EMAIL" \
#         --role=author \
#         --user_pass="$WP_USER_PASSWORD" \
#         --allow-root

#     if [ $? -ne 0 ]; then
#         echo "Error creating WordPress user"
#         exit 1
#     fi

# else
#     echo "---- WordPress already installed ----"
# fi

# echo "---- Starting PHP-FPM ----"
# exec "$@"


