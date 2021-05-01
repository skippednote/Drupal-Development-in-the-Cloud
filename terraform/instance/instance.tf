# We will be provisioning AWS infrastructure
provider "aws" {
  region = "ap-south-1"
}

# ec2 instance for cloud development
resource "aws_instance" "instance" {
  ami                    = "ami-0d758c1134823146a"
  instance_type          = "t2.large"
  availability_zone      = "ap-south-1a"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security.id]
  key_name               = aws_key_pair.key.key_name

  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
}

# Security rules to allow traffic on specific protocols and ports
resource "aws_security_group" "security" {
  name   = "security"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port   = "22"
    protocol    = "tcp"
    to_port     = "22"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Code Server"
    from_port   = "8080"
    protocol    = "tcp"
    to_port     = "8080"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = file("../../keys/key.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  # enable_classiclink   = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet" {
  availability_zone       = "ap-south-1a"
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

output "ip" {
  value = aws_instance.instance.public_ip
}

output "instance_id" {
  value = aws_instance.instance.id
}
