server {
    listen 80;
    listen [::]:80;
    server_name homeassistant.home.weinbender.io;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    ssl_certificate     /etc/letsencrypt/live/home.weinbender.io/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/home.weinbender.io/privkey.pem;

    server_name homeassistant.home.weinbender.io;
    
    proxy_set_header    Upgrade     $http_upgrade;
    proxy_set_header    Connection  "upgrade";
    
    location / {
            proxy_pass http://192.168.1.78:8123;
    }
}