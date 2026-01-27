
# srcs/requirements/mariadb/Dockerfile:

FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# COPY conf/my.cnf /etc/mysql/my.cnf
COPY tools/script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
CMD ["/usr/bin/mysqld_safe", "--datadir=/var/lib/mysql"]
