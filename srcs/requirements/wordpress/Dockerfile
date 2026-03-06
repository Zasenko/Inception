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
    && rm -rf /var/lib/apt/lists/

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/
COPY ./tools/entrypoint.sh .

RUN chmod +x entrypoint.sh

EXPOSE 9000

CMD ["./entrypoint.sh"]
