THIS_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
PASSWORD_FILE=vault-password

# Generate the vault-password.secret file
op inject -i $THIS_DIR/$PASSWORD_FILE.secret.tmpl -o $THIS_DIR/$PASSWORD_FILE.secret
