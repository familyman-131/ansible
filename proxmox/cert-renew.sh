#!/bin/bash

domain="example.com"

# comment after first use
certbot certonly --standalone --agree-tos -m reports@it-man.pro -d ${domain}

/usr/bin/certbot renew >> /var/log/letsencrypt/letsencrypt.log
rm -rf /etc/pve/local/pve-ssl.pem
rm -rf /etc/pve/local/pve-ssl.key
rm -rf /etc/pve/pve-root-ca.pem
cp /etc/letsencrypt/live/${domain}/fullchain.pem  /etc/pve/local/pve-ssl.pem
cp /etc/letsencrypt/live/${domain}/privkey.pem /etc/pve/local/pve-ssl.key
cp /etc/letsencrypt/live/${domain}/chain.pem /etc/pve/pve-root-ca.pem
service pveproxy restart
service pvedaemon restart
