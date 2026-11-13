FROM linuxserver/webtop:latest

# Environment defaults
ENV TZ=Asia/Kolkata \
    TITLE="Lipan Alpine Cloud PC" \
    PUID=1000 \
    PGID=1000 \
    PORT=10000

# Install lightweight utility packages
RUN apk update && \
    apk add --no-cache \
        nginx \
        curl \
        wget \
        bash \
        procps \
        nano \
        python3 \
        git \
        htop \
        tree && \
    rm -rf /var/cache/apk/*

# Copy Nginx template configuration
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Copy initialization script into LinuxServer s6 hook
COPY 10-nginx-init.sh /custom-cont-init.d/10-nginx-init.sh
RUN chmod +x /custom-cont-init.d/10-nginx-init.sh

# Create custom service directories and copy supervised service scripts
RUN mkdir -p /custom-services.d/nginx /custom-services.d/memguard

COPY run-nginx.sh /custom-services.d/nginx/run
RUN chmod +x /custom-services.d/nginx/run

COPY run-memguard.sh /custom-services.d/memguard/run
RUN chmod +x /custom-services.d/memguard/run

# Copy MemGuard daemon script
COPY memguard.sh /usr/local/bin/memguard.sh
RUN chmod +x /usr/local/bin/memguard.sh

# Expose Render default port
EXPOSE 10000
