#!/bin/bash
# Garantir que os ficheiros do html têm permissões corretas
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Executar o Nginx em foreground
exec nginx -g "daemon off;"
