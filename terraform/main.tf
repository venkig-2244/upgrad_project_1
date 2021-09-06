# ========================================================
# Terraform script to create infrastructure for Project 1
# Author: Venkatesh G
# Email: itsvenkatesh@gmail.com
# ========================================================

terraform {
  required_version = ">= 0.14.31"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.28"
    }
  }
}

# ========================================================
# VPC Object - vpc_project1
# ========================================================
resource "aws_vpc" "vpc_project1" {
        cidr_block              = var.vpc_project1_cidr
        instance_tenancy        = "default"
        enable_dns_hostnames    = true

        tags = {
                Name = "${var.project}-vpc"
        }
}

# ========================================================
# Internet Gateway Object - igw_project1
# ========================================================
resource "aws_internet_gateway" "igw_project1" {
        vpc_id                  = aws_vpc.vpc_project1.id
        tags = {
                Name = "${var.project}-igw"
        }

}

# ========================================================
# Subnet Object - public1
# ========================================================
resource "aws_subnet" "public1" {
        vpc_id                  = aws_vpc.vpc_project1.id
        cidr_block              = var.public1.cidr
        availability_zone       = var.public1.az
        map_public_ip_on_launch = true

        tags = {
                Name = "${var.project}-public1"
        }
}

# ========================================================
# Subnet Object - public2
# ========================================================
resource "aws_subnet" "public2" {
        vpc_id                  = aws_vpc.vpc_project1.id
        cidr_block              = var.public2.cidr
        availability_zone       = var.public2.az
        map_public_ip_on_launch = true

        tags = {
                Name = "${var.project}-public2"
        }
}

# ========================================================
# Subnet Object - private1
# ========================================================
resource "aws_subnet" "private1" {
        vpc_id                  = aws_vpc.vpc_project1.id
        cidr_block              = var.private1.cidr
        availability_zone       = var.private1.az
        map_public_ip_on_launch = false

        tags = {
                Name = "${var.project}-private1"
        }
}

# ========================================================
# Subnet Object - private2
# ========================================================
resource "aws_subnet" "private2" {
        vpc_id                  = aws_vpc.vpc_project1.id
        cidr_block              = var.private2.cidr
        availability_zone       = var.private2.az
        map_public_ip_on_launch = false

        tags = {
                Name = "${var.project}-private2"
        }
}

# ========================================================
# Elastic IP Object. This is required for NAT Gateway
# ========================================================
resource "aws_eip" "nat" {
        vpc                     = true
        tags = {
                Name = "${var.project}-natip"
        }
}

# ========================================================
# NAT Gateway Object - nat
# ========================================================
resource "aws_nat_gateway" "nat" {
        allocation_id           = aws_eip.nat.id
        subnet_id               = aws_subnet.public1.id

        tags = {
                Name = "${var.project}-natgw"
        }
}

# ========================================================
# Route Table Object - public
# ========================================================
resource "aws_route_table" "public" {
        vpc_id                  = aws_vpc.vpc_project1.id

        route {
                cidr_block      = "0.0.0.0/0"
                gateway_id      = aws_internet_gateway.igw_project1.id
        }

        tags = {
                Name = "${var.project}-rtpub"
        }
}

# ========================================================
# Route Table Object - private
# ========================================================
resource "aws_route_table" "private" {
        vpc_id                  = aws_vpc.vpc_project1.id
        route {
                cidr_block      = "0.0.0.0/0"
                nat_gateway_id  = aws_nat_gateway.nat.id
        }

        tags = {
                Name = "${var.project}-rtpri"
        }
}

# ========================================================
# Route Table association object - required to associate public subnets to Route Table
# ========================================================
resource "aws_route_table_association" "public1" {
        subnet_id               = aws_subnet.public1.id
        route_table_id          = aws_route_table.public.id
}

# ========================================================
# Route Table association object - required to associate public subnets to Route Table
# ========================================================
resource "aws_route_table_association" "public2" {
        subnet_id               = aws_subnet.public2.id
        route_table_id          = aws_route_table.public.id
}

# ========================================================
# Route Table association object - required to associate Private subnets to Route table
# ========================================================
resource "aws_route_table_association" "private1" {
        subnet_id               = aws_subnet.private1.id
        route_table_id          = aws_route_table.private.id
}

# ========================================================
# Route Table association object - required to associate Private subnets to Route table
# ========================================================
resource "aws_route_table_association" "private2" {
        subnet_id               = aws_subnet.private2.id
        route_table_id          = aws_route_table.private.id
}

# ========================================================
# Security Group for bastion, app and jenkins instances
# ========================================================
data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

# ========================================================
# security group object for bastian
# ========================================================
resource "aws_security_group" "bastion" {
        name                    = "${var.project}-bastion"
        description             = "Allows 22 from local ip address"
        vpc_id                  = aws_vpc.vpc_project1.id

        ingress {
                from_port        = 22
                to_port          = 22
                protocol         = "tcp"
                cidr_blocks      = [ "${chomp(data.http.local_ip.body)}/32"]
        }

        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

        tags = {
                Name = "${var.project}-bastion"
        }
}

# ========================================================
# security group object for app server
# ========================================================
resource "aws_security_group" "private_sg" {
        name                    = "${var.project}-appserver"
        description             = "Private SG"
        vpc_id                  = aws_vpc.vpc_project1.id
  
        ingress {
    
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                security_groups  = [ aws_security_group.bastion.id ]
        }
  
        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

        tags = {
                Name = "${var.project}-appserver"
        }
}

# ========================================================
# security group object for app server
# ========================================================
resource "aws_security_group" "public_sg" {
    
        name        = "${var.project}-app"
        description = "Allows 3306 from webserver & 22 from bastion"
        vpc_id      = aws_vpc.vpc_project1.id

        ingress {
    
                from_port        = 80
                to_port          = 80
                protocol         = "tcp"
                cidr_blocks      = [ "${chomp(data.http.local_ip.body)}/32" ]

        }
  
        egress {
                from_port        = 0
                to_port          = 0
                protocol         = "-1"
                cidr_blocks      = [ "0.0.0.0/0" ]
                ipv6_cidr_blocks = [ "::/0" ]
        }

        tags = {
                Name = "${var.project}-app"
        }
}

# ========================================================
# Key Pair for logging into EC2 instances
# ========================================================
resource "aws_key_pair" "key" {

  key_name   = "${var.project}-keypair"
  public_key = file("upgrad-keypair.pub")
  tags = {
    Name = "${var.project}-keypair"
  }
    
}

# ========================================================
# Bastion - EC2 instance
# ========================================================
resource  "aws_instance"  "bastion" {
    
        ami                           =     var.ami_for_ec2
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.bastion.id ]
        subnet_id                     =     aws_subnet.public1.id  
  
        tags = {
                Name = "${var.project}-bastion"
        }
}

# ========================================================
# app - EC2 instance
# ========================================================
resource  "aws_instance"  "app" {
    
        ami                           =     var.ami_for_ec2
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.public_sg.id ]
        subnet_id                     =     aws_subnet.private1.id  
        tags = {
                Name = "${var.project}-app"
        }
}

# ========================================================
# jenkins - EC2 instance
# ========================================================
resource  "aws_instance"  "jenkins" {

        ami                           =     var.ami_for_ec2
        instance_type                 =     "t2.micro"
        associate_public_ip_address   =     true
        key_name                      =     aws_key_pair.key.key_name
        vpc_security_group_ids        =     [  aws_security_group.private_sg.id ]
        subnet_id                     =     aws_subnet.public2.id
        tags = {
                Name = "${var.project}-jenkins"
        }
}

# ========================================================
# End of file
# ========================================================

