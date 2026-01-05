FROM debian:bullseye

# Install php-fpm & utilities
# add these for problem solving before && rm...:    net-tools iproute2 iputils-ping netcat\
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli wget unzip mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# finds binary & makes generic link
RUN ln -s /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm || true

# makes WordPress folder
RUN mkdir -p /var/www/html

# copy and permissions for entrypoint and configs
COPY tools/wp-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-entrypoint.sh
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN chmod +x /etc/php/7.4/fpm/pool.d/www.conf

# Install wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN rm -f /etc/php/7.4/fpm/pool.d/www.conf.default || true

# starts php-fpm in foreground
ENTRYPOINT ["wp-entrypoint.sh"]
CMD ["php-fpm", "-F"]

