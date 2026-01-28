


FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*


RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \ 
    -keyout /etc/ssl/inception.key \
    -out /etc/ssl/inception.crt \
    -subj="/C=MA/ST=dzasenko/L=dzasenko/O=1337 School/OU=dzasenko/CN=dzasenko.42.fr"

COPY ./tools/script.sh /tmp/certs.sh

RUN chmod +x /tmp/certs.sh

COPY ./conf/default.conf /etc/nginx/sites-available/default


ENTRYPOINT ["/tmp/certs.sh"]