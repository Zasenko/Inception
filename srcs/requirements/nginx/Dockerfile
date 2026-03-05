FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default.conf /etc/nginx/sites-available/default
COPY ./tools/script.sh script.sh

RUN chmod +x script.sh

EXPOSE 443

CMD ["./script.sh"]
