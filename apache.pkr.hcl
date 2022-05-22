

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type    = string
  default = "ami-039c735a27bd2d204"
}

variable "public_subnet_id" {
  type    = string
  default = "subnet-05879b88350bb719e"
}

locals {
  #release_id = formatDateTime(utcNow(),"MM-dd-yyyy")
  release_id = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.
source "amazon-ebs" "firstrun" {
  ami_name                              = join("-", ["jango-app", local.release_id])
  instance_type                         = "t2.micro"
  iam_instance_profile                  = "FOR_FUSION_Console_Admins"
  region                                = var.region
  subnet_id                             = var.public_subnet_id
  associate_public_ip_address           = true
  security_group_filter {
    filters = {
      "tag:Class": "Dev-sec-group"
    }
  }



source_ami_filter {
    filters = {
      image-id = "${var.ami_id}"
      #name                = "al2022-ami-*"
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
    execute_command   = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script            = "./setup.sh"
    expect_disconnect = true
  }

}



