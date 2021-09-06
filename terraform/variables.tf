# ========================================================
# Terraform variables to create infrastructure for Project 1
# Author: Venkatesh G
# Email: itsvenkatesh@gmail.com
# ========================================================
variable "project" {
        default = "upgrad-project-1"
}

variable "vpc_project1_cidr" {
        default = "192.168.0.0/16"
}

variable "public1" {
        type            = map
        default = {
                "cidr"  = "192.168.101.0/24"
		"az"	= "us-east-1a"
        }

}

variable "public2" {
        type            = map
        default = {
                "cidr"  = "192.168.102.0/24"
		"az"    = "us-east-1b"
        }

}


variable "private1" {
        type            = map
        default = {
                "cidr"  = "192.168.1.0/24"
		"az"	= "us-east-1a"
        }

}

variable "private2" {
        type            = map
        default = {
                "cidr"  = "192.168.2.0/24"
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