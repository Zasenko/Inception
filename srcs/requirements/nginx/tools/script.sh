#!/bin/bash

mkdir -p /etc/nginx/ssl
chmod 700 /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/inception.key -out /etc/nginx/ssl/inception.crt -subj="/C=MA/ST=dzasenko/L=dzasenko/O=1337 School/OU=dzasenko/CN=dzasenko.42.fr"

chmod 644 /etc/nginx/ssl/inception.crt /etc/nginx/ssl/inception.key

# Start nginx
nginx -g "daemon off;"

