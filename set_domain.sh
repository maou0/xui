#!/bin/bash

source bash_scripts_config

YELLOW='\033[0;33m'
NC='\033[0m'

if [[ -z "$domain" ]]; then
    echo -e "\n${YELLOW}Не указан домен в файле ./bash_scripts_config${NC}\n"
    exit 1
elif [[ -z "$token" ]]; then
    echo -e "\n${YELLOW}Не указан токен в файле ./bash_scripts_config${NC}\n"
    exit 1
elif ((ssh_port > 65535 || ssh_port < 49152)); then
    echo -e "\n${YELLOW}Значение ssh_port в файле ./bash_scripts_config должно быть от 49152 до 65535${NC}\n"
    exit 1
fi

apt install openssl curl ca-certificates certbot -y
hostnamectl set-hostname "$domain"
curl "https://freemyip.com/update?token=${token}&domain=${domain}"
(crontab -l; echo "30 2 * * 0 curl \"https://freemyip.com/update?token=${token}&domain=${domain}\"") | crontab -
mkdir -p /root/xui/cert/
certbot certonly --standalone --agree-tos --register-unsafely-without-email -d "$domain"
cp /etc/letsencrypt/live/${domain}/fullchain.pem /root/xui/cert/
cp /etc/letsencrypt/live/${domain}/privkey.pem /root/xui/cert/
(crontab -l; echo "0 0 * * * [ \$((\$(date +\%s)/86400\%91)) -eq 0 ] && certbot renew && cp /etc/letsencrypt/live/${domain}/privkey.pem /root/xui/cert && cp /etc/letsencrypt/live/${domain}/fullchain.pem /root/xui/cert") | crontab -
