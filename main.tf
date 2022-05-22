

#module "vpc" {
#  source = "cloudposse/vpc/aws"
#  namespace = "eg"
#  stage     = "test"
#  name      = "demo-1"
#
#  ipv4_primary_cidr_block = "10.0.0.0/16"
#
#  assign_generated_ipv6_cidr_block = false
#}
#
#module "dynamic_subnets" {
#  source = "cloudposse/dynamic-subnets/aws"
#  namespace          = "eg"
#  stage              = "test"
#  name               = "demo"
#  availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
#  vpc_id             = module.vpc.vpc_id
#  igw_id             = module.vpc.igw_id
#  cidr_block         = "10.0.0.0/16"
#}
#
#
#
#module "label" {
#  source = "cloudposse/label/null"
#  # Cloud Posse recommends pinning every module to a specific version
#  # version = "x.x.x"
#  namespace  = "eg"
#  stage      = "prod"
#  name       = "bastion"
#  attributes = ["public"]
#  delimiter  = "-"
#
#  tags = {
#    "BusinessUnit" = "XYZ",
#    "Snapshot"     = "true"
#  }
#}
#
#
#module "sg" {
#  source = "cloudposse/security-group/aws"
#  allow_all_egress = true
#
#  rules = [
#    {
#      key         = "HTTP"
#      type        = "ingress"
#      from_port   = 80
#      to_port     = 80
#      protocol    = "tcp"
#      cidr_blocks = []
#      self        = true
#      description = "Allow HTTP from inside the security group"
#    }
#  ]
#
#  vpc_id  = module.vpc.vpc_id
#
#  context = module.label.context
#}
#
data "aws_ami" "jango" {
  most_recent = true

  filter {
    name   = "name"
    values = ["jango-app-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["587719168126"] # Canonical
}


data "aws_default_vpc" "jango" {
  id = var.vpc_id
}

data "aws_default_security_group" "jango" {
  vpc_id = ${data.aws_default_vpc.jango.id}
}


data "aws_subnet" "default" {
  filter {
    name   = "tag:Name"
    values = ["dev-subnet-1"] 
  }
}

module "instance" {
  source = "cloudposse/ec2-instance/aws"
  instance_type               = var.instance_type
  vpc_id                      = ${data.aws_default_vpc.jango.id}
  security_groups             = ${data.aws_default_security_group.jango.id}
  subnet                      = ${data.aws_subnet.jango.id}
  name                        = "Hello World"
  ami                         = ${data.aws_ami.jango.id}
  ami_owner                   = "587719168126"
  namespace                   = "eg"
  availability_zone           = "us-east-1a"
  stage                       = "dev"
}


