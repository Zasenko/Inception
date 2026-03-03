FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/script.sh script.sh

RUN chmod +x script.sh

COPY ./conf/default.conf /etc/nginx/sites-available/default

EXPOSE 443

CMD ["./script.sh"]

