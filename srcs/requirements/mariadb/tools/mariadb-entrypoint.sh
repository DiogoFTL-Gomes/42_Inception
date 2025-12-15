#!/bin/bash
set -e

# Garante diretório de socket
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Inicializa DB se primeira vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando MariaDB..."
    mysqld --initialize-insecure --user=mysql

    # Lê passwords a partir de Docker secrets
    ROOT_PASS=$(cat /run/secrets/db_root_password)
    WP_PASS=$(cat /run/secrets/db_password)

    # Start temporário do MariaDB
    mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    pid="$!"

    mysql=( mysql --protocol=socket -uroot )

    # Cria DB e user
    "${mysql[@]}" <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
        CREATE DATABASE wordpress;
        CREATE USER 'wp_user'@'%' IDENTIFIED BY '${WP_PASS}';
        GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
        FLUSH PRIVILEGES;
EOSQL

    kill "$pid"
    wait "$pid"
fi

# Start MariaDB normalmente
exec su mysql -s /bin/bash -c "$*"

