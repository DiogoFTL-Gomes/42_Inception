FROM debian:bullseye

# Instala php-fpm e utilitários
RUN apt-get update && apt-get install -y \
    php-fpm php-mysql php-cli wget unzip \
    && rm -rf /var/lib/apt/lists/*


# Descobre o binário e cria link genérico
RUN ln -s /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm || true

# Cria diretório do WordPress
RUN mkdir -p /var/www/html

# Copia index.html / index.php de teste
COPY tools/index.html /var/www/html/index.html

# Copia entrypoint
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Arranca php-fpm no foreground
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm", "-F"]

