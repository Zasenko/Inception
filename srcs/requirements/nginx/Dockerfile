FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default.conf /etc/nginx/sites-available/default
COPY ./tools/entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

EXPOSE 443

CMD ["./entrypoint.sh"]
