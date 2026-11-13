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

# Copy MemGuard supervised service directly into /custom-services.d/
COPY memguard.sh /custom-services.d/memguard
RUN chmod +x /custom-services.d/memguard

# Expose Render default port
EXPOSE 10000
