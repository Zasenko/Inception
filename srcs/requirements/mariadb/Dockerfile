# srcs/requirements/mariadb/Dockerfile:
FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client && rm -rf /var/lib/apt/lists/*

COPY ./tools/installer.sh .

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x installer.sh

EXPOSE 3306

CMD ["./installer.sh"]

# RUN apt-get update && apt-get install -y \
#     mariadb-server \
#     mariadb-client \
#     && rm -rf /var/lib/apt/lists/*

# COPY conf/my.cnf /etc/mysql/my.cnf
# COPY tools/script.sh /usr/local/bin/script.sh

# RUN chmod +x /usr/local/bin/script.sh

# EXPOSE 3306

# CMD ["/usr/local/bin/script.sh"]

