FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório para certificados
RUN mkdir -p /etc/nginx/ssl

# Gerar certificado self-signed
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42Lisboa/CN=ddiogo-f.42.fr"

# Copiar configuração personalizada
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/index.html /var/www/html/index.html
# Copiar o entrypoint
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Tornar entrypoint ativo
ENTRYPOINT ["/entrypoint.sh"]






# Copiar configuração personalizada
#COPY conf/nginx.conf /etc/nginx/nginx.conf
#COPY tools/index.html /var/www/html/index.html

# Nginx deve rodar em foreground como PID 1
#CMD ["nginx", "-g", "daemon off;"]
