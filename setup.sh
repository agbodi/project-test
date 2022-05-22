#!/bin/bash
sleep 30

sudo amazon-linux-extras enable nginx1.12

sudo yum install wget nginx net-tools php php-common php-cli php-gd php-curl php-mysql php-fpm -y

#sudo cp files/php.conf /etc/php-fpm.d/www.conf

sudo chown -R root.nginx /var/lib/php

sudo systemctl enable php-frm && sudo systemctl start pho-frm

#sudo cp files/nginx.conf /etc/nginx/nginx.conf

sudo mkdir -p /var/www/app

#sudo cp -r files/php /var/www/app

sudo chown -R root.nginx /var/www/app

#sudo cp -r files/application.conf /etc/nginx/conf.d/app.conf

sudo systemctl enable nginx && sudo systemctl start nginx

sudo amazon-linux-extras enable mariadb10.5

sudo yum install -y mariadb

sudo systemctl enable mariadb && sudo systemctl start mariadb

#- name: Recreate database
#      shell:
#        cmd: |
#          mariadb <<EOF
#          DROP USER IF EXISTS user_manager;
#          DROP DATABASE IF EXISTS user_inventory;
#          CREATE DATABASE user_inventory;
#          CREATE USER user_manager IDENTIFIED BY 'Qwerty123';
#          GRANT ALL PRIVILEGES ON user_inventory.* TO user_manager;
#          EOF
#    - name: Copy DB DDL file
#      copy:
#        src: "./files/user_management.sql"
#        dest: "/home/ec2-user/user_management.sql"
#        mode: 0644
#    - name: Build database tables
#      shell: "mariadb user_inventory < /home/ec2-user/user_management.sql"
