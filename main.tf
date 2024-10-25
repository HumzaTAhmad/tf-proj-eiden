provider "aws" {
  region = "us-east-1" # Change to your desired region
}

terraform {
  backend "s3" {
    bucket = "tf-proj-eiden"
    key    = "tf-state/terraform.tfstate"
    region = "us-east-1"
  }
}

/* resource "aws_instance" "instance_one" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id[0]
  iam_instance_profile = var.iam_role_name
  vpc_security_group_ids = [aws_security_group.ec2_rules.id]

  root_block_device {
    volume_size = 80 
  }
}

resource "aws_instance" "instance_two" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id[1]
  iam_instance_profile = var.iam_role_name
  vpc_security_group_ids = [aws_security_group.ec2_rules.id]

  root_block_device {
    volume_size = 80 
  }
} */

resource "aws_launch_template" "eiden_launch_template" {
  name_prefix   = "test_image"
  image_id      = "ami-06b21ccaeff8cd686"
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

  # Attach the existing EBS volume
  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size           = 100
      delete_on_termination = false
    }
  }
}

resource "aws_autoscaling_group" "eiden_asg" {

  vpc_zone_identifier = [ var.subnet_id[0], var.subnet_id[1] ]
 
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2
  

  launch_template {
    id      = aws_launch_template.eiden_launch_template.id
    version = "$Latest"
  }


  target_group_arns = [aws_lb_target_group.eiden_target_group.arn]

  health_check_type         = "ELB" 
  health_check_grace_period = 300  
  
}

resource "aws_lb" "eiden_nlb" {
  name               = "eiden-nlb"
  internal           = true # Internal NLB
  load_balancer_type = "network"
  subnets            = [var.subnet_id[0], var.subnet_id[1]] # Private subnets for internal NLB
}

resource "aws_lb_listener" "my_nlb_listener" {
  load_balancer_arn = aws_lb.eiden_nlb.arn
  port              = 443
  protocol          = "TCP" # For Network Load Balancer

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eiden_target_group.arn
  }
}

resource "aws_lb_target_group" "eiden_target_group" {
  name        = "eidentargetgroup"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id # Replace with your VPC ID
  target_type = "instance"     # Target type is instance for EC2 instances

  health_check {
    port     = 443
    protocol = "TCP"
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


/* resource "aws_ebs_volume" "test_volume1" {
  availability_zone = "us-east-1a"
  size              = 100

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_ebs_volume" "test_volume2" {
  availability_zone = "us-east-1a"
  size              = 100

  tags = {
    Name = "HelloWorld"
  }
} */

/* resource "aws_volume_attachment" "attatch_instance_one" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test_volume1.id
  instance_id = aws_instance.instance_one.id
}

resource "aws_volume_attachment" "attatch_instance_two" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.test_volume2.id
  instance_id = aws_instance.instance_two.id
} */


/* resource "aws_vpc" "main" {
 cidr_block = "10.1.0.0/16"
 
 tags = {
   Name = "Project VPC"
 }
}

resource "aws_subnet" "sub1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "sub2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "private"
  }
} */

