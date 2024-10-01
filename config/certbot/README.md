# Certbot

Generate Let's Encrypt certs.

## Installing Certbot

You'll need certbot and the appropriate plugin for the DNS provider

```
sudo apt install python3-certbot python3-certbot-dns-cloudflare
```

## Running Certbot

Look at the `run.sh` script. Make sure 1 Password is configured first so that you can pull in the credentials for the domain registrar (cloudflare).
