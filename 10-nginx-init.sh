#!/bin/bash
set -e

PORT="${PORT:-10000}"
echo "[INIT] Initializing Alpine Webtop on Port: $PORT"

# Ensure runtime directories exist
mkdir -p /run/nginx /var/log/nginx /var/lib/nginx/tmp

# Render dynamic port into nginx.conf
if [ -f /etc/nginx/nginx.conf.template ]; then
    sed "s/__PORT__/$PORT/g" /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
    echo "[INIT] Nginx configuration generated successfully."
fi

# Ensure correct permissions
chmod 755 /run/nginx /var/log/nginx
