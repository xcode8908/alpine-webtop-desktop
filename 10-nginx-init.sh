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

# Generate .htpasswd with SHA1 hash for authentication
python3 -c "
import os, hashlib, base64
user = os.environ.get('CUSTOM_USER', 'lipan')
pw = os.environ.get('PASSWORD', 'Lipan8908@')
sha = base64.b64encode(hashlib.sha1(pw.encode()).digest()).decode()
with open('/etc/nginx/.htpasswd', 'w') as f:
    f.write(f'{user}:{{SHA}}{sha}\n')
print(f'[INIT] HTTP Basic Auth configured for user: {user}')
"

# Ensure correct permissions
chmod 755 /run/nginx /var/log/nginx
chmod 644 /etc/nginx/.htpasswd
