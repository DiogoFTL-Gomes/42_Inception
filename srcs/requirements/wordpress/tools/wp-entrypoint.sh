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
while ! mysqladmin ping \
    -h "$DB_HOST" \
    -u "$DB_USER" \
    -p"$DB_PASS" \
    --silent; do
    echo "Aguardando MariaDB..."
    sleep 2
    WAIT_TIMEOUT=$((WAIT_TIMEOUT-2))
    if [ $WAIT_TIMEOUT -le 0 ]; then
        echo "Erro: MariaDB não respondeu a tempo"
        exit 1
    fi
done

# Cria wp-config.php se não existir
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Criando wp-config.php..."
    wp config create \
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
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat $WP_ADMIN_PASSWORD_FILE)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html \
        --skip-email
fi

# Executa php-fpm no foreground
exec "$@"
