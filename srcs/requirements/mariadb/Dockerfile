FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/script.sh .

RUN chmod +x script.sh

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

CMD ["./script.sh"]

