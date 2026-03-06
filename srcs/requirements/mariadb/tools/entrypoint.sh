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
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql --rpm
        # mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm
    fi
    
    echo "Starting MariaDB for setup..."
    mysqld_safe --user=mysql --skip-networking & PID=$!
    
    for i in {1..60}; do
        echo "Waiting for MariaDB: attempt $i"
        # mysqladmin ping -h localhost --silent 2>/dev/null
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done
# mysqladmin ping -h localhost --silent 2>/dev/null
    if ! mysqladmin ping --silent 2>/dev/null; then
        echo "Error: MariaDB failed to start"
        exit 1
    fi

    echo "Creating DataBase and user..."
    mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "Stopping temporary MariaDB..."
    mysqladmin --user=root --password="$MYSQL_ROOT_PASSWORD" shutdown 2>/dev/null || kill $PID
    wait $PID 2>/dev/null || true
else
    echo "MariaDB already initialized."
fi

echo "Starting MariaDB in foreground..."
exec mysqld_safe --user=mysql
