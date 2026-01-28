#!/bin/bash

# Создание директории для сертификатов
mkdir -p /root/certs && cd /root/certs

# Генерация самоподписанного сертификата
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx-selfsigned.key -out nginx-selfsigned.crt -subj "/C=RU/ST=Moscow/L=Moscow/O=MyCompany/OU=IT/CN=$DOMAIN_NAME"

# Установка прав на файлы сертификатов
chmod 600 nginx-selfsigned.key
chmod 600 nginx-selfsigned.crt

# Запуск Nginx
exec nginx -g "daemon off;"