# Gotta make sure the directory exists
sudo mkdir -p /etc/certbot

# Generate the ini files with secrets
op inject -i cloudflare.ini.tmpl -o cloudflare.ini
sudo mv cloudflare.ini /etc/certbot/cloudflare.ini

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 30 \
  --dns-cloudflare-credentials /etc/certbot/cloudflare.ini \
  -d *.home.weinbender.io

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-propagation-seconds 30 \
  --dns-cloudflare-credentials /etc/certbot/cloudflare.ini \
  -d *.home.weinbender.io
