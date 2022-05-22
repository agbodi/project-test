#!/bin/bash
sleep 30

sudo amazon-linux-extras enable nginx1.12

sudo yum install wget nginx net-tools php php-common php-cli php-gd php-curl php-mysql php-fpm -y

sudo mkdir -p /var/www/app

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
