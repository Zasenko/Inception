#!/bin/bash
set -e

DATA_DIR=/var/lib/mysql
SOCKET_DIR=/run/mysqld

mkdir -p $SOCKET_DIR $DATA_DIR /var/log/mysql
chown -R mysql:mysql $SOCKET_DIR $DATA_DIR /var/log/mysql

if [ ! -d "$DATA_DIR/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=$DATA_DIR
    mysqld_safe --datadir=$DATA_DIR --skip-networking &
    pid="$!"

    timeout=30
    count=0
    until mysqladmin ping --silent; do
        sleep 2
        count=$((count+1))
        if [ $count -ge $timeout ]; then
            echo "Error: MariaDB failed to start" >&2
            exit 1
        fi
    done

    # создаём пользователя и базу
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mysqladmin shutdown
    wait "$pid"
fi

# запускаем MariaDB в foreground
exec mysqld_safe --datadir=$DATA_DIR