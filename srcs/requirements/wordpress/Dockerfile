# srcs/requirements/wordpress/Dockerfile:
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    wget \
    mariadb-client \
    net-tools \
    curl \
    && rm -rf /var/lib/apt/lists/

COPY ./tools/script.sh .
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/

RUN chmod +x script.sh

EXPOSE 9000

CMD ["./script.sh"]



    # && service php8.2-fpm start

# # Создаем директорию, если она не существует
# RUN mkdir -p /run/php /var/run/php /var/www/html
# WORKDIR /var/www/html
# RUN chown -R www-data:www-data /var/www/html


# # COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
# COPY tools/script.sh /usr/local/bin/script.sh
# RUN chmod +x /usr/local/bin/script.sh

# RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

# # Меняем владельца


# EXPOSE 9000

# CMD ["/usr/local/bin/script.sh"]
