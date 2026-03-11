#!/bin/bash
set -e

mkdir -p /var/lib/mysql
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld
chmod 755 /var/run/mysqld

ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD")
USER_PASSWORD=$(cat "$MYSQL_PASSWORD")

if [ ! -d "/var/lib/mysql/mysql" ] || [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Installing MariaDB..."
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    fi
    
    echo "Starting temporary MariaDB for setup..."
    mysqld --user=mysql --skip-networking & PID=$!
    
    TIMEOUT=60
    COUNT=0
    while ! mysqladmin -uroot ping --silent >/dev/null 2>&1; do
        if [ $COUNT -ge $TIMEOUT ]; then
            echo "Error: MariaDB is still unavailable after $TIMEOUT seconds"
            exit 1
        fi
        echo "MariaDB is unavailable: waiting 2 seconds..."
        sleep 2
        COUNT=$((COUNT + 2))
    done

    echo "Creating DataBase and user..."
    mysql -uroot << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$USER_PASSWORD';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "Stopping temporary MariaDB..."
    mysqladmin --user=root --password="$ROOT_PASSWORD" shutdown 2>/dev/null || kill $PID
    wait $PID 2>/dev/null || true
else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql
