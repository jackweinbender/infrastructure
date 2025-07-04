server {
    listen  80;
    server_name homeassistant.home.weinbender.io;

    proxy_set_header    Upgrade     $http_upgrade;
    proxy_set_header    Connection  "upgrade";

    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name homeassistant.home.weinbender.io;

    client_max_body_size 20M;

    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_certificate /etc/letsencrypt/live/home.weinbender.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/home.weinbender.io/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/home.weinbender.io/chain.pem;

    resolver 192.168.1.1 valid=30s;
    set $ip_address homeassistant;


    proxy_set_header    Upgrade     $http_upgrade;
    proxy_set_header    Connection  "upgrade";
    
    location / {
           proxy_pass http://$ip_address:8123;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_set_header X-Forwarded-Host $http_host;
    }
}