#!/bin/bash
# Corrige permissões
chown -R www-data:www-data /var/www/html

# Garante que /run/php existe para o socket
mkdir -p /run/php
chown -R www-data:www-data /run/php

# Arranca php-fpm
exec "$@"
