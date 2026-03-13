#!/bin/bash
set -e

SSL_DIR=/etc/nginx/ssl
KEY=$SSL_DIR/inception.key
CRT=$SSL_DIR/inception.crt

echo "Starting nginx container..."

mkdir -p $SSL_DIR
chmod 700 $SSL_DIR

if [ ! -f $KEY ] || [ ! -f $CRT ]; then
    echo "SSL certificate not found. Generating new self-signed certificate..."

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $KEY -out $CRT -subj="/C=Austria/ST=Vienna/L=Vienna/O=42 School/OU=42 School/CN=dzasenko.42.fr"
    chmod 600 "$KEY"
    chmod 644 "$CRT"

    echo "SSL certificate generated successfully."
else
    echo "SSL certificate found."
fi

echo "Starting nginx..."
exec nginx -g "daemon off;"
