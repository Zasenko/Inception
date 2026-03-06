#!/bin/bash
set -e

mkdir -p /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld
chmod 755 /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --rpm
    
    echo "Starting MariaDB for setup..."
    mysqld --user=mysql --skip-networking & PID="$!"
    
    TIMEOUT=60
    COUNT=0
    while ! mysql --host="$WP_HOST" --port="$WP_PORT" --user="$WP_USER" --password="$(cat "$WP_PASSWORD")" -e "SELECT 1;" >/dev/null 2>&1
    do
        if [ "$COUNT" -ge "$TIMEOUT" ]; then
            echo "ERROR: MariaDB failed to start"
            exit 1
        fi
        echo "Waiting for MariaDB... ${COUNT}/${TIMEOUT}s"
        sleep 1
        COUNT=$((COUNT + 1))
    done
    echo "MariaDB is ready!"

    echo "Creating DataBase and user..."
    mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat "$MYSQL_ROOT_PASSWORD")';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat "$MYSQL_PASSWORD")';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "Stopping temporary MariaDB..."
    mysqladmin --user=root --password="$(cat "$MYSQL_ROOT_PASSWORD")" shutdown 2>/dev/null || kill $PID
    wait $PID 2>/dev/null || true
else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql
