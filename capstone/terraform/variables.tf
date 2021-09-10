# ========================================================
# Terraform variables to create infrastructure for Capstone Project 
# Author: Venkatesh G
# Email: itsvenkatesh@gmail.com
# ========================================================
variable "project" {
    default = "upgrad-capstone-project"
}

variable "vpc_capstone_project_cidr" {
    default = "10.0.0.0/16"
}

variable "public1" {
    type            = map
    default = {
        "cidr"  = "10.0.1.0/24"
        "az"	= "us-east-1a"
    }

}

variable "public2" {
    type            = map
    default = {
        "cidr"  = "10.0.2.0/24"
        "az"    = "us-east-1b"
    }

}


variable "private1" {
    type            = map
    default = {
        "cidr"  = "10.0.10.0/24"
        "az"	= "us-east-1a"
    }

}

variable "private2" {
        type            = map
        default = {
            "cidr"  = "10.0.20.0/24"
		    "az"	= "us-east-1b"
        }

}

variable "ami_for_ec2" {
  type    = string
  default = "ami-09e67e426f25ce0d7"
}

# ========================================================
# End of file
# ========================================================