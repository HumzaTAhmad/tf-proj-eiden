provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-humza-proj"
    key    = "tf-state/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_launch_template" "humza_launch_template" {
  name_prefix   = "humza-launch-template"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.iam_role_name
  }

  vpc_security_group_ids = [aws_security_group.ec2_rules.id]

  block_device_mappings {
    device_name = "/dev/xvda" #root
    ebs {
      volume_size           = 80
      delete_on_termination = true
    }
  }


  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size           = 100
      delete_on_termination = true
    }
  }
}

resource "aws_autoscaling_group" "humza_asg" {

  vpc_zone_identifier = [var.subnet_id[0], var.subnet_id[1]]

  desired_capacity = 2
  max_size         = 2
  min_size         = 2


  launch_template {
    id      = aws_launch_template.humza_launch_template.id
    version = "$Latest"
  }
}

resource "aws_security_group" "ec2_rules" {
  name        = "ec2_rules"
  description = "Allow ec2 and https inbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  depends_on        = [aws_security_group.ec2_rules]
  security_group_id = aws_security_group.ec2_rules.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_ingress_rule" "allow_instance" {
  depends_on                   = [aws_security_group.ec2_rules]
  security_group_id            = aws_security_group.ec2_rules.id
  referenced_security_group_id = aws_security_group.ec2_rules.id
  from_port                    = 4001
  ip_protocol                  = "tcp"
  to_port                      = 4003
}


