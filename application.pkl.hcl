

variable "region" {
  type    = string
  default = "us-east-1"
}

#variable "ami_id" {
#  type    = string
#  default = "ami-039c735a27bd2d204"
#}

variable "public_subnet_id" {
  type    = string
  default = "subnet-05879b88350bb719e"
}

locals {
  release_id = formatdate("DDMMYYYYhhmm", timestamp())
}

source "amazon-ebs" "firstrun" {
  ami_name                              = join("-", ["jango-app", local.release_id])
  instance_type                         = "t2.micro"
  iam_instance_profile                  = "FOR_FUSION_Console_Admins"
  region                                = var.region
  subnet_id                             = var.public_subnet_id
  ami_regions                           =  [ "us-east-1", "us-west-2" ]
  associate_public_ip_address           = true
  security_group_filter {
    filters = {
      "tag:Class": "Dev-sec-group"
    }
  }



source_ami_filter {
    filters = {
      #image-id = "${var.ami_id}"
      name                = "jango-base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["587719168126"]
  }


  ssh_username = "ec2-user"
  tags = {
    Name        = join("-", ["jango-app", local.release_id])
    Environment = "global"
    Group       = "DevOps"
    Purpose     = "Jango Base Image"
    Release_Id  = local.release_id
  }
  snapshot_tags = {
    Name        = join("-", ["jango-app", local.release_id])
    Environment = "global"
    Group       = "DevOps"
    Purpose     = "Jango Base Image"
    Release_Id  = local.release_id
  }
  encrypt_boot          = true
  force_deregister      = false
  force_delete_snapshot = false
}

# a build block invokes sources and runs provisioning steps on them.
build {
 sources = ["source.amazon-ebs.firstrun"]

  provisioner "shell" {
  
   execute_command  = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
   scripts =  ["./setup.sh"]
   expect_disconnect = "true"
  }

  provisioner "file" {
    source = "files/php"
    destination = "/tmp/app"
  }
  provisioner "shell" {
    inline = ["sudo mv /tmp/app /var/www/"]
  }
  provisioner "file" {
    source = "files/php.conf"
    destination = "/tmp/php.conf"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/php.conf /etc/php-fpm.d/www.conf"]
  }
  
   provisioner "file" {
    source = "files/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

   provisioner "shell" {
    inline = ["sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf"]
  }
   provisioner "file" {
    source = "files/application.conf"
    destination = "/tmp/app.conf"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/app.conf /etc/nginx/conf.d/app.conf"]
  }

   provisioner "file" {
    source = "files/mariadb"
    destination = "/tmp/mariadb"
   }

   provisioner "file" {
    source = "files/user_management.sql"
    destination = "/tmp/user_management.sql"
  }
    provisioner "shell" {
    inline = [ "sudo mariadb < /tmp/mariadb" ]
  }

   provisioner "shell" {
    inline = [ "sudo mariadb user_inventory < /tmp/user_management.sql" ]
  }

  provisioner "shell" {
    inline = [ "sudo chown -R root.nginx /var/lib/php  /var/www/app" ]
  }
 provisioner "shell" {
    inline = [ "sudo systemctl enable php-fpm && sudo systemctl start php-fpm && sudo systemctl enable nginx && sudo systemctl start nginx" ]
  } 
}
