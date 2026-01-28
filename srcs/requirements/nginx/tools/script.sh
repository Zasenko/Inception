#!/bin/bash

# Static values for the certificates and domain
ssl_certificate="/etc/ssl/inception.crt"
ssl_certificate_key="/etc/ssl/inception.key"
nginx_domain="dzasenko.42.fr"

# Replace the placeholders in the nginx configuration file
sed -i "s|my_cert|$ssl_certificate|g" /etc/nginx/sites-available/default
sed -i "s|my_key|$ssl_certificate_key|g" /etc/nginx/sites-available/default
sed -i "s|DOMAIN_NAME|$nginx_domain|g" /etc/nginx/sites-available/default

# Start nginx
nginx -g "daemon off;"
