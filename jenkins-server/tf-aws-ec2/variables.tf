variable "aws_region" {
    description = "The region where the infrastructure should be deployed to"
    default = "eu-west-1"
    type = string
}

variable "aws_account_id" {
    description = "AWS Account ID"
    type = string
}

variable "backend_jenkins_bucket" {
    description = "S3 bucket where jenkins terraform state file will be stored"
    type = string
}

variable "backend_jenkins_bucket_key" {
    description = "bucket key for the jenkins terraform state file"
    type = string
}

variable "vpc_name" {
  description = "VPC Name for Jenkins Server VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for Jenkins Server VPC"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR range"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "jenkins_security_group" {
  description = "Instance Type"
  type        = string
}

variable "jenkins_ec2_instance" {
  description = "Instance Type"
  type        = string
}

variable "instance_ami" {
  description = "Amazon EC2 Instance AMI"
  type = string
}
