#!/bin/bash
set -e

# Создаем директорию если нет
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Инициализация базы если пустая
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

# Запускаем MariaDB в фоне
mysqld --user=mysql & pid="$!"

# Ждем готовности
echo "Waiting for MariaDB..."
until mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB started."

# Создаем базу и пользователя
if ! mysql -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then
    echo "Creating database and user..."

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    echo "Database setup complete."
fi


# Останавливаем временный сервер
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Запускаем MariaDB как основной процесс (PID 1)
exec mysqld --user=mysql