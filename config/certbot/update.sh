# Script to update the certbot config and run the certbot
# cert ACME challenge stuff

THIS_CONFIG_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
CERTBOT_CONFIG_DIR="/etc/certbot"

# Gotta make sure the directory exists
sudo mkdir -p $CERTBOT_CONFIG_DIR

# Generate the ini files with secrets
op inject -i $THIS_CONFIG_DIR/cloudflare.ini.tmpl -o cloudflare.ini
sudo mv cloudflare.ini $CERTBOT_CONFIG_DIR/cloudflare.ini

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 30 \
  --dns-cloudflare-credentials $CERTBOT_CONFIG_DIR/cloudflare.ini \
  -d *.home.weinbender.io
