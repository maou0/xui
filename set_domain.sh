#!/bin/bash

source bash_scripts_config

if [[ -z "$domain" ]]; then
    echo -e "Не указан домен в файле ./bash_scripts_config"
    exit 1
elif [[ -z "$token" ]]; then
    echo -e "Не указан токен в файле ./bash_scripts_config"
    exit 1
fi

apt install openssl curl ca-certificates certbot -y
hostnamectl set-hostname "$domain"
curl "https://freemyip.com/update?token=${token}&domain=${domain}"
(crontab -l; echo "30 2 * * 0 curl \"https://freemyip.com/update?token=${token}&domain=${domain}\"") | crontab -
certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$domain"
cp /etc/letsencrypt/live/${domain}/fullchain.pem /root/xui/cert/
cp /etc/letsencrypt/live/${domain}/privkey.pem /root/xui/cert/
(crontab -l; echo "0 0 * * * [ \$((\$(date +\%s)/86400\%91)) -eq 0 ] && certbot renew && cp /etc/letsencrypt/live/${domain}/privkey.pem /root/xui/cert && cp /etc/letsencrypt/live/${domain}/fullchain.pem /root/xui/cert") | crontab -
