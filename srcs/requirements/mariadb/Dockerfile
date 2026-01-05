FROM debian:bullseye

# Install MariaDB & utils
# add these for problem solving before && rm...:    netcat iputils-ping \
RUN apt-get update && apt-get install -y \
    mariadb-server \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# make folder for socket runtime
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

# Copy config
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy entrypoint
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["mariadb-entrypoint.sh"]
CMD ["mysqld", "--console"]
