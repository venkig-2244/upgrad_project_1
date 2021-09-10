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
# VPC Object - vpc_capstone-project
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
# Internet Gateway Object - igw_project1
# ========================================================
resource "aws_internet_gateway" "igw_project1" {
        vpc_id  = aws_vpc.vpc_capstone_project.id
        tags = {
                Name = "${var.project}-igw"
        }

}

# ==========================================================
# End of file 
# ==========================================================