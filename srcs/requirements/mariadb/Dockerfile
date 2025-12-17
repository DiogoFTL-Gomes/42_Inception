FROM debian:bullseye

# Instala MariaDB
RUN apt-get update && apt-get install -y \
    mariadb-server \
    gosu \
    && rm -rf /var/lib/apt/lists/*


# Garante diretório de runtime para o socket
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

# Copia configuração de ip address
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copia entrypoint
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["mariadb-entrypoint.sh"]
CMD ["mysqld", "--console"]
