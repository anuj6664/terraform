//credentials
provider "aws" {
      region     = "${var.region}"
      access_key = "${var.access_key}"
      secret_key = "${var.secret_key}"
 }


//vpc
resource "aws_vpc" "vpc" {
   cidr_block = "10.0.0.0/16"
   instance_tenancy = "default"
   enable_dns_support = "true"
   enable_dns_hostnames = "true"
   tags = {
     Name = "digbi-vpc"
   }
}

//private subnet
resource "aws_subnet" "private_subnet" {
   vpc_id = "${aws_vpc.vpc.id}"
   cidr_block = "10.0.0.0/24"
   tags = {
     Name = "private-subnet"
  }
} 

//public subnet 
resource "aws_subnet" "public_subnet" {
   vpc_id = "${aws_vpc.vpc.id}"
   cidr_block = "10.0.1.0/24"
   tags = {
     Name = "public-subnet"
  }
}

//Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

//ec2 instance
resource "aws_instance" "ec2" {
  subnet_id     = "${aws_subnet.public_subnet.id}"
  ami           = var.ami_id 
  instance_type = var.instance_type
  associate_public_ip_address = true
  tags = {
    Name = "personal-ec2"

  }
}
