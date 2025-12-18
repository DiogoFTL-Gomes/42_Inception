#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

ROOT_PASS=$(cat /run/secrets/db_root_password)
WP_PASS=$(cat /run/secrets/db_password)

# Arranca MariaDB temporariamente
gosu mysql mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
pid="$!"

# Espera pelo socket
until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
    sleep 1
done

mysql --protocol=socket -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
    CREATE DATABASE IF NOT EXISTS wordpress;
    CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY '${WP_PASS}';
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
    FLUSH PRIVILEGES;
EOSQL

kill "$pid"
wait "$pid"

# Arranque final
exec gosu mysql "$@"

