#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# arranque temporário SEM rede
gosu mysql mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
pid="$!"

until mysqladmin --socket=/var/run/mysqld/mysqld.sock ping --silent; do
    sleep 1
done

ROOT_PASS="$(cat /run/secrets/db_root_password)"
WP_PASS="$(cat /run/secrets/db_password)"

# verificar se wp_user existe (usando root COM password)
USER_EXISTS=$(MYSQL_PWD="$ROOT_PASS" mysql \
    --protocol=socket -uroot -N -e \
    "SELECT COUNT(*) FROM mysql.user WHERE user='wp_user';" || echo 0)

if [ "$USER_EXISTS" = "0" ]; then
    echo "📦 Initializing WordPress database"

    MYSQL_PWD="$ROOT_PASS" mysql --protocol=socket -uroot <<EOSQL
ALTER USER 'root'@'localhost'
IDENTIFIED VIA mysql_native_password
USING PASSWORD('${ROOT_PASS}');

CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY '${WP_PASS}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EOSQL

    echo "✅ Database initialized"
fi

# shutdown LIMPO (com password!)
MYSQL_PWD="$ROOT_PASS" mysqladmin \
    --protocol=socket -uroot shutdown

wait "$pid"

# arranque final
exec gosu mysql mysqld --datadir=/var/lib/mysql --console
