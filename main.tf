########################
# Networking resources #
########################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.infra-prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.infra-prefix}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.infra-prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.infra-prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

resource "aws_security_group" "app_sg" {
  name        = "${var.infra-prefix}-app-sg"
  description = "Allow all protocols from my public IP; egress all"
  vpc_id      = aws_vpc.main.id

  # Ingress: all (-1) from your IP only
  ingress {
    description = "All traffic from my public IP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.my_ip_cidr]
  }

  # Egress: all to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.infra-prefix}-app-sg"
  }
}

###############
# Key Pair.   #
###############

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.infra-prefix}-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name        = "${var.infra-prefix}-key"
  }
}

####################
# local provission #
####################

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.infra-prefix}-key.pem"
  file_permission = "0600"
}

################
# EC2 Instance #
################

resource "aws_instance" "example" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  key_name  = aws_key_pair.keypair.key_name
  user_data = "${file("update.sh")}"

  tags = {
    Name        = "${var.infra-prefix}-ec2-${count.index}"
  }
}