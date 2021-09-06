# ========================================================
# Terraform support script to create infrastructure for Project 1
# Author: Venkatesh G
# Email: itsvenkatesh@gmail.com
# ========================================================

output "App-Server-Public-IP" {
        value = aws_instance.app.public_ip
}

output "Bastion-Server-Public-IP" {
        value = aws_instance.bastion.public_ip
}

output "App-Server-Private-IP" {
        value = aws_instance.app.private_ip

}

output "Jenkins-Server-Private-IP" {
        value = aws_instance.jenkins.private_ip

}


output "Bastion-Server-IP" {
  value = aws_instance.bastion.public_ip
}

#output "Load-Balancer" {
#  value = aws_lb.alb.arn
#}


output "VPC-ARN" {
  value = aws_vpc.vpc_project1.arn
}

output "Internet-Gateway-ARN" {
  value = aws_internet_gateway.igw_project1.arn
}


# ========================================================
# End of file
# ========================================================
