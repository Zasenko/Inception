#!/bin/bash
set -e

echo "Starting MARIADB setup..."
echo "WP_HOST: $WP_HOST"
echo "WP_NAME: $WP_NAME" 
echo "WP_USER: $WP_USER"
echo "WP_PORT: $WP_PORT"
echo "MYSQL_PASSWORD: $MYSQL_PASSWORD" 
echo "MYSQL_DATABASE: $MYSQL_DATABASE"
echo "MYSQL_USER: $MYSQL_USER"
echo "WP_PASSWORD: $WP_PASSWORD"
echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "DOMAIN_NAME: $DOMAIN_NAME"


DATA_DIR=/var/lib/mysql
SOCKET_DIR=/var/run/mysqld
LOGS_DIR=/var/log/mysql

# Create necessary directories and set permissions
echo "Setting directories..."
mkdir -p $SOCKET_DIR $DATA_DIR $LOGS_DIR
chown -R mysql:mysql $SOCKET_DIR $DATA_DIR $LOGS_DIR
chmod 755 $SOCKET_DIR
chmod 755 $LOGS_DIR

# Initialize the database if it has not been done already
if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql --datadir=$DATA_DIR
    mysqld_safe --datadir=$DATA_DIR --skip-networking &
    pid="$!"

    # Wait for MariaDB to start
    timeout=30
    count=0
    until mysqladmin ping --silent; do
        sleep 2
        count=$((count+1))
        if [ $count -ge $timeout ]; then
            echo "Error: MariaDB failed to start after $timeout seconds" >&2
            exit 1
        fi
    done

    # Configuring MariaDB: setting root password, creating DB, and users
    echo "Configuring MariaDB..."
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

# Creating the WordPress user and granting privileges
CREATE USER IF NOT EXISTS '${WP_USER}'@'%' IDENTIFIED BY '${WP_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${WP_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    # Verify database and user creation
    echo "Checking database and user creation..."
    if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" | grep -q "${MYSQL_DATABASE}"; then
        echo "Error: Database ${MYSQL_DATABASE} was not created."
        exit 1
    fi

    if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT User FROM mysql.user WHERE User='${MYSQL_USER}';" | grep -q "${MYSQL_USER}"; then
        echo "Error: User ${MYSQL_USER} was not created."
        exit 1
    fi

    if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT User FROM mysql.user WHERE User='${WP_USER}';" | grep -q "${WP_USER}"; then
        echo "Error: User ${WP_USER} was not created."
        exit 1
    fi

    mysqladmin shutdown
    wait "$pid"
else
    echo "---- MariaDB already initialized ----"
fi

# Start MariaDB with necessary parameters
echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=$DATA_DIR


# DATA_DIR=/var/lib/mysql
# SOCKET_DIR=/var/run/mysqld
# LOGS_DIR=/var/log/mysql

# # Создаем необходимые директории и назначаем правильные права
# echo "Setting directories..."
# mkdir -p $SOCKET_DIR $DATA_DIR $LOGS_DIR
# chown -R mysql:mysql $SOCKET_DIR $DATA_DIR $LOGS_DIR
# chmod 755 $SOCKET_DIR
# chmod 755 $LOGS_DIR

# # Инициализация базы данных, если еще не выполнена
# if [ ! -d "$DATA_DIR/mysql" ]; then
#     echo "Initializing MariaDB..."

#     mariadb-install-db --user=mysql --datadir=$DATA_DIR
#     mysqld_safe --datadir=$DATA_DIR --skip-networking &
#     pid="$!"

#     # Пытаемся подключиться к базе данных MariaDB
#     timeout=30
#     count=0
#     until mysqladmin ping --silent; do
#         sleep 2
#         count=$((count+1))
#         if [ $count -ge $timeout ]; then
#             echo "Error: MariaDB failed to start after $timeout seconds" >&2
#             exit 1
#         fi
#     done

#     # Настройка базы данных и пользователей
#     echo "Configuring MariaDB..."
#     mysql -u root <<EOF
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
# CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
# FLUSH PRIVILEGES;
# EOF
#     # Проверка успешности создания базы данных и пользователя
#     echo "Checking database and user creation..."
#     if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" | grep -q "${MYSQL_DATABASE}"; then
#         echo "Error: Database ${MYSQL_DATABASE} was not created."
#         exit 1
#     fi

#     if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT User FROM mysql.user WHERE User='${MYSQL_USER}';" | grep -q "${MYSQL_USER}"; then
#         echo "Error: User ${MYSQL_USER} was not created."
#         exit 1
#     fi

#     mysqladmin shutdown
#     wait "$pid"
# else
#     echo "---- MariaDB already initialized ----"
# fi

# # Запуск MariaDB с необходимыми параметрами
# echo "Starting MariaDB..."
# exec mysqld --user=mysql --datadir=$DATA_DIR
