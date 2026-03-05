#!/bin/bash
set -e

echo "Starting MariaDB setup..."

mkdir -p /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld
chmod 755 /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Installing MariaDB..."
        mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm
    fi
    
    echo "Starting MariaDB for setup..."
    mysqld_safe --user=mysql --skip-networking --skip-grant-tables &
    MYSQL_PID=$!
    
    echo "Waiting for MariaDB to be ready..."
    TIMEOUT=60
    COUNT=0
    # until mysqladmin ping --silent 2>/dev/null; do
    until mysqladmin ping --silent; do
        sleep 1
        COUNT=$((COUNT + 1))
        if [ $COUNT -ge $TIMEOUT ]; then
            echo "Error: MariaDB failed to start after $TIMEOUT seconds, exiting..."
            exit 1
        fi
    done
    echo "MariaDB is read!"
    
    echo "Creating DataBase and user..."
    mysql -u root << EOF
FLUSH PRIVILEGES;
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "Stopping temporary MariaDB..."
    mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown 2>/dev/null || kill $MYSQL_PID
    wait $MYSQL_PID 2>/dev/null || true
else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."
exec mysqld_safe --user=mysql
