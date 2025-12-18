#!/bin/bash
set -e

# Corrige permissões
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Garante que /run/php existe para o socket do php-fpm
mkdir -p /run/php
chown -R www-data:www-data /run/php

DB_PASS="$(cat $DB_PASSWORD_FILE)"

# Espera pela base de dados estar pronta
echo "Aguardando MariaDB com autenticação real..."
until mysql \
    -h "$DB_HOST" \
    -u "$DB_USER" \
    -p"$DB_PASS" \
    "$DB_NAME" \
    -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

# Descarregar WordPress
if [ ! -f /var/www/html/wp-load.php ]; then
    echo "A descarregar WordPress..."
    wp core download \
        --allow-root \
        --path=/var/www/html
fi

rm -f /var/www/html/wp-config.php

# Cria wp-config.php se não existir
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Criando wp-config.php..."
    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$(cat $DB_PASSWORD_FILE)" \
        --dbhost="$DB_HOST" \
        --skip-check
fi

# Instala WordPress se não estiver instalado
if ! wp core is-installed --path=/var/www/html >/dev/null 2>&1; then
    echo "Instalando WordPress..."
    wp core install \
        --allow-root \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat $WP_ADMIN_PASSWORD_FILE)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html \
        --skip-email
fi

# Arranca PHP-FPM em TCP 9000
exec php-fpm7.4 -y /etc/php/7.4/fpm/php-fpm.conf -F

# Executa php-fpm no foreground
#exec "$@"
