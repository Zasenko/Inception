# srcs/requirements/nginx/Dockerfile:
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/script.sh scriptt.sh

RUN chmod +x scriptt.sh

COPY ./conf/default.conf /etc/nginx/sites-available/default

EXPOSE 443 80

CMD ["./scriptt.sh"]

