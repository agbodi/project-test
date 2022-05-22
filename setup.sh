#!/bin/bash
sleep 30

sudo amazon-linux-extras enable nginx1.12

sudo yum install wget nginx net-tools php php-common php-cli php-gd php-curl php-mysql php-fpm -y

sudo mkdir -p /var/www/app

sudo amazon-linux-extras enable mariadb10.5

sudo yum install -y mariadb

sudo systemctl enable mariadb && sudo systemctl start mariadb

