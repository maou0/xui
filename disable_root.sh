#!/bin/bash

source bash_scripts_config

adduser "$sudo_user"
usermod -aG sudo "$sudo_user"
sed -i "s/#Port 22/Port ${ssh_port}/g" /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl restart ssh
sed -i 's|root:x:0:0:root:/root:/bin/bash|root:x:0:0:root:/root:/sbin/nologin|g' /etc/passwd
