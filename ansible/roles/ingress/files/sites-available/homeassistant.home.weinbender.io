# Jellyfin Reverse Proxy Configuration

# DNS resolution
resolver 192.168.1.1 valid=30s;
resolver_timeout 5s;

server {
    listen 80;
    listen [::]:80;
    server_name homeassistant.home.weinbender.io;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;

    server_name homeassistant.home.weinbender.io;

    # Set the maximum body size for client requests
    client_max_body_size 20M;
    
    # SSL Configuration
    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/home.weinbender.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/home.weinbender.io/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/home.weinbender.io/chain.pem;
    
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # use a variable to store the upstream proxy
    set $upstream homeassistant:8123;

    # Security / XSS Mitigation Headers
    add_header X-Content-Type-Options "nosniff";
    add_header Permissions-Policy "accelerometer=(), ambient-light-sensor=(), battery=(), bluetooth=(), camera=(), clipboard-read=(), display-capture=(), document-domain=(), encrypted-media=(), gamepad=(), geolocation=(), gyroscope=(), hid=(), idle-detection=(), interest-cohort=(), keyboard-map=(), local-fonts=(), magnetometer=(), microphone=(), payment=(), publickey-credentials-get=(), serial=(), sync-xhr=(), usb=(), xr-spatial-tracking=()" always;
    # Content Security Policy
    add_header Content-Security-Policy "default-src https: data: blob: ; img-src 'self' https://* ; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' https://www.gstatic.com https://www.youtube.com blob:; worker-src 'self' blob:; connect-src 'self'; object-src 'none'; frame-ancestors 'self'; font-src 'self'";

    location / {
        # Proxy main Jellyfin traffic
        proxy_pass http://$upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;

        # Disable buffering when the nginx proxy gets very resource heavy upon streaming
        proxy_buffering off;
    }

    location /socket {
        # Proxy Jellyfin Websockets traffic
        proxy_pass http://$upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_set_header X-Forwarded-Host $http_host;
    }
}