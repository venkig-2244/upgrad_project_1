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
# S3 bucket creation
# ========================================================
resource "aws_s3_bucket" "tf-backup" {
  bucket = "tf-backup-bucket-upgrad"
  acl    = "private"

  tags = {
    Name        = "Backup"
  }
}

# ========================================================
# VPC Object - vpc_capstone_project
# ========================================================
resource "aws_vpc" "vpc_capstone_project" {
        cidr_block              = var.vpc_capstone_project_cidr
        instance_tenancy        = "default"
        enable_dns_hostnames    = true

        tags = {
                Name = "${var.project}-vpc"
        }
}

# ========================================================
# Internet Gateway Object - igw_capstone_project
# ========================================================
resource "aws_internet_gateway" "igw_capstone_project" {
        vpc_id  = aws_vpc.vpc_capstone_project.id
        tags = {
                Name = "${var.project}-igw"
        }

}

# ========================================================
# Subnet Object - public1
# ========================================================
resource "aws_subnet" "public1" {
        vpc_id                  = aws_vpc.vpc_capstone_project.id
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
        vpc_id                  = aws_vpc.vpc_capstone_project.id
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
        vpc_id                  = aws_vpc.vpc_capstone_project.id
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
        vpc_id                  = aws_vpc.vpc_capstone_project.id
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
resource "aws_eip" "nat_capstone" {
        vpc                     = true
        tags = {
                Name = "${var.project}-natip"
        }
}

# ========================================================
# NAT Gateway Object - nat
# ========================================================
resource "aws_nat_gateway" "nat_gateway_capstone" {
        allocation_id           = aws_eip.nat_capstone.id
        subnet_id               = aws_subnet.public1.id

        tags = {
                Name = "${var.project}-natgw"
        }
}

# ========================================================
# Route Table Object - public
# ========================================================
resource "aws_route_table" "public" {
        vpc_id                  = aws_vpc.vpc_capstone_project.id

        route {
                cidr_block      = "0.0.0.0/0"
                gateway_id      = aws_internet_gateway.igw_capstone_project.id
        }

        tags = {
                Name = "${var.project}-rtpub"
        }
}

# ========================================================
# Route Table Object - private
# ========================================================
resource "aws_route_table" "private" {
        vpc_id                  = aws_vpc.vpc_capstone_project.id
        route {
                cidr_block      = "0.0.0.0/0"
                nat_gateway_id  = aws_nat_gateway.nat_gateway_capstone.id
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

# ==========================================================
# End of file 
# ==========================================================