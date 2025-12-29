FROM debian:bullseye

# add these for problem solving before && rm...:
#    net-tools iproute2 iputils-ping netcat\
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# makes folder for certificates
RUN mkdir -p /etc/nginx/ssl

# generate self-signed certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42Lisboa/CN=ddiogo-f.42.fr"

# Copy config
COPY conf/nginx.conf /etc/nginx/nginx.conf
# Copy entrypoint
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# activate entrypoint
ENTRYPOINT ["/entrypoint.sh"]
