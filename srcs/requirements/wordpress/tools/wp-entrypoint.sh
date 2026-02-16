#!/bin/bash
set -e

WP_PATH="/var/www/html"

# Garantir que o volume existe e é writeable
mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

# Runtime PHP
mkdir -p /run/php
chown -R www-data:www-data /run/php

cd "$WP_PATH"

DB_PASS="$(cat "$DB_PASSWORD_FILE")"
ADMIN_PASS="$(cat "$WP_ADMIN_PASSWORD_FILE")"

echo "Waiting for MariaDB..."

until mariadb -h"$DB_HOST" -u"$DB_USER" -p"$(cat $DB_PASSWORD_FILE)" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done

echo "MariaDB is ready."

# Download WordPress
if [ ! -f wp-load.php ]; then
    wp core download \
        --allow-root \
        --path="$WP_PATH"
fi

# Criar wp-config.php
if [ ! -f wp-config.php ]; then
    wp config create \
        --allow-root \
        --path="$WP_PATH" \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$DB_HOST" \
        --skip-check
fi

# Instalar WordPress
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
    wp core install \
        --allow-root \
        --path="$WP_PATH" \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
fi

exec "$@"