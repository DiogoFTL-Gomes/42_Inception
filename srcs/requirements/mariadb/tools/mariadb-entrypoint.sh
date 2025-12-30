#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

INIT_FLAG="/var/lib/mysql/.wp_initialized"

# arranque temporário para garantir socket
gosu mysql mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
pid="$!"

until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
    sleep 1
done

if [ ! -f "$INIT_FLAG" ]; then
    echo "📦 Configuração inicial do WordPress DB"

    ROOT_PASS="$(cat /run/secrets/db_root_password)"
    WP_PASS="$(cat /run/secrets/db_password)"

    mysql --protocol=socket -uroot <<EOSQL
ALTER USER 'root'@'localhost'
IDENTIFIED VIA mysql_native_password
USING PASSWORD('${ROOT_PASS}');
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EOSQL

    touch "$INIT_FLAG"
    echo "✅ WordPress DB configurada"
fi

kill "$pid"
wait "$pid"

#chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

# arranque normal
exec gosu mysql mysqld --datadir=/var/lib/mysql --console
