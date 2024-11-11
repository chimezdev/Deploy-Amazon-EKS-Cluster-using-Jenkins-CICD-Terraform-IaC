variable "aws_region" {
    description = "The region where the infrastructure should be deployed to"
    default = "eu-west-1"
    
}

variable "aws_account_id" {
    description = "AWS Account ID"
}

variable "backend_jenkins_bucket" {
    description = "S3 bucket where jenkins terraform state file will be stored"
    
}

variable "backend_jenkins_bucket_key" {
    description = "bucket key for the jenkins terraform state file"
    
}

variable "vpc_name" {
  description = "VPC Name for Jenkins Server VPC"
  
}

variable "vpc_cidr" {
  description = "VPC CIDR for Jenkins Server VPC"
  
}

variable "public_subnets" {
  description = "Subnets CIDR range"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  
}

variable "jenkins_security_group" {
  description = "Instance Type"
  
}

variable "jenkins_ec2_instance" {
  description = "Instance Type"
  
}

variable "instance_ami" {
  description = "Amazon EC2 Instance AMI"
  
}

variable "DEPLOY_ROLE" {
  default = "arn:aws:iam::038462750799:role/pp-deployment-role" # please replace with appropraite value
}
