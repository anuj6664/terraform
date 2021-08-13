//credentials
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


//vpc
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "digbi-vpc"
  }
}

//private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "private-subnet"
  }
}

//public subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public-subnet"
  }
}

//Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

//ec2 instance
resource "aws_instance" "ec2" {
  subnet_id                   = aws_subnet.public_subnet.id
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = "deployer-key"
  tags = {
    Name = "personal-ec2"

  }
}

//security group
resource "aws_security_group" "ssh" {
  name   = "allow ssh login"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//attaching security group to ec2 network interface
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = aws_instance.ec2.primary_network_interface_id
}

//creating key-pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDHrolaM+xDo93qfWB2FOPR9RJatP2olipKBO/N/auf/fp05urf2G/+oG4vXgMyo9XbxbSesrpCfk6IVlQl9TVsrkc8mGns1stakNkkKNk/+q9ExUlpDnIKNkqTVoisSpYA0APEt5HobBXSdhwS2OpuD6tgUOYtvfUgTT2rXDbqkA8mlBH8w1PJmftUZsou9VSBMTWS5XxUmbIcKCT3Nq6cwp6UcsIGsv61wpG+QDkOGfEohWqsCBZQ27PZPKfk+yFe43gw5R/121Gltl+D17rW5yRGxmwIJdNhT1zxd1CWWeHANYTZTy9k7N7t6uso+vjcWEEUWxUd9O2XlFpuqOh anuj@Anujs-MacBook-Pro.local"
}


//route table
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
       tags = {
         Name = "MyRoute"
    }
  }


//main route table
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.table.id
}
