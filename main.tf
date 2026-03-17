resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "demo-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
  tags = {
    Name = "demo-subnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "demo-igw"
  }
}

resource "aws_route_table" "RT1" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "demo-rt"
  }

}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_route_table_association" "RTA2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.RT1.id
}

resource "aws_s3_bucket" "demo-bucket" {
  bucket = "my-bucket-tiku-12345"
  tags = {
    Name = "demo-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "demo-bucket-block" {
  bucket = aws_s3_bucket.demo-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTPinbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-key"
  # Paste the output from the ssh-keygen command here
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfnpYmiYxgJe1SkIaQ7LQYFBKWEI8gm9Oj23jr1goyhY17vR68ifJ/MSakUwnJJww4Z/sGFHNM7KcBimJ2MypmHmDZr9sZePYlP3YtM6OymaVm6kdZTQn8kDzi7mnfFFeLA5+Y1HGq6sSCAefzyxDdxuhRIDmQdv8WfOgYOvqUhv/DbawS8hV0F3+4FXD9MrJcd4jl25U7cEvCCqhtWTYONNUYwuB7Neb5DiDmEE0Yd/zdoLDXgZD/WXNoDDXfDLIMXUyDMX89XIOIBeeKoKr1aDpx0uFBlbxpSl+O5D89Rt+wj3LywBz0yi9yXRaLCIjHn9jY8Lxq1w9YNxbXV3Zh"
}

resource "aws_instance" "web-server1" {
  ami                    = "ami-06e3c045d79fd65d9"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet1.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y apache2 unzip curl
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            sudo systemctl start apache2
            sudo systemctl enable apache2
            echo "<H1>Hello, World from Shipra!</H1>" | sudo tee /var/www/html/index.html
            sudo apt update && sudo apt install awscli -y
            EOF
  tags = {
    Name = "web-server1"
  }
}
resource "aws_instance" "web-server2" {
  ami                    = "ami-06e3c045d79fd65d9"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet2.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y apache2 unzip curl
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            unzip awscliv2.zip
            sudo ./aws/install
            sudo systemctl start apache2
            sudo systemctl enable apache2
            echo "<H1>Hello, World from Kishu!</H1>" | sudo tee /var/www/html/index.html
            sudo apt update && sudo apt install awscli -y
            EOF
  tags = {
    Name = "web-server2"
  }
}

resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow HTTP inbound traffic to LB"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_lb"
  }
}

resource "aws_lb" "demo-lb" {
  name               = "demo-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups    = [aws_security_group.lb-sg.id]
  tags = {
    Name = "demo-lb"
  }
}

resource "aws_lb_target_group" "demo-target" {
  name        = "demo-target"
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = aws_vpc.myvpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = 80
  }

  tags = {
    Name = "demo-target"
  }
}

resource "aws_lb_target_group_attachment" "lb-target-attachment1" {
  target_group_arn = aws_lb_target_group.demo-target.arn
  target_id        = aws_instance.web-server1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "lb-target-attachment2" {
  target_group_arn = aws_lb_target_group.demo-target.arn
  target_id        = aws_instance.web-server2.id
  port             = 80
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.demo-lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo-target.arn
  }
}

output "aws_lb_dns_name" {
  value       = aws_lb.demo-lb.dns_name
  description = "DNS name of the load balancer"
}

resource "aws_iam_role" "ec2_role" {
    name = "ec2-role"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
        }
    EOF

}

resource "aws_iam_policy" "s3_full_access" {
    name = "s3-full-access"
    policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
            }
        ]
        }
    EOF
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-instance-profile"
  role = aws_iam_role.ec2_role.name
}