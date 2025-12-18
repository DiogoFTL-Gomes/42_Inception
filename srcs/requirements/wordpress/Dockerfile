FROM debian:bullseye

# Instala php-fpm e utilitários
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli wget unzip mariadb-client \
    && rm -rf /var/lib/apt/lists/*



# Descobre o binário e cria link genérico
RUN ln -s /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm || true

# Cria diretório do WordPress
RUN mkdir -p /var/www/html

# Copia entrypoint
COPY tools/wp-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-entrypoint.sh
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
RUN chmod +x /etc/php/7.4/fpm/pool.d/www.conf


# Instalar wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN rm -f /etc/php/7.4/fpm/pool.d/www.conf.default || true

# Arranca php-fpm no foreground
ENTRYPOINT ["wp-entrypoint.sh"]
#CMD ["php-fpm", "-F"]

