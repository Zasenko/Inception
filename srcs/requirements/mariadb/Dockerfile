FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/entrypoint.sh .

RUN chmod +x entrypoint.sh

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

CMD ["./entrypoint.sh"]
