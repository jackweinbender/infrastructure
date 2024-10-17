# Script to update the certbot config and run the certbot
# cert ACME challenge stuff

source config/helpers.sh
echo this_dir
CERTBOT_CONFIG_DIR="/etc/certbot"

# # Gotta make sure the directory exists
# sudo mkdir -p $CERTBOT_CONFIG_DIR

# # Generate the ini files with secrets
# op inject -i $THIS_CONFIG_DIR/cloudflare.ini.tmpl -o cloudflare.ini
# sudo mv cloudflare.ini $CERTBOT_CONFIG_DIR/cloudflare.ini
