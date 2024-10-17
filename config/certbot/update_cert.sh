CERTBOT_CONFIG_DIR="/etc/certbot"

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 30 \
  --dns-cloudflare-credentials $CERTBOT_CONFIG_DIR/cloudflare.ini \
  -d *.home.weinbender.io