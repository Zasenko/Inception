#!/bin/sh
set -e

ROOT_PASS=$(cat /run/secrets/db_root_password)
WP_PASS=$(cat /run/secrets/db_password)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
fi

mysqld --skip-networking &
pid="$!"

until mysqladmin ping --silent; do
    sleep 1
done

mysql -u root <<EOF
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROOT_PASS}');
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysqladmin shutdown
wait "$pid"

exec mysqld

