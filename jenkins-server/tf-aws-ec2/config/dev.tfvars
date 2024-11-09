
aws_region = "eu-west-1"
aws_account_id = "038462750799"
backend_jenkins_bucket = "palm-cicd-artifact"
backend_jenkins_bucket_key = "jenkins/terraform.tfstate"
vpc_name       = "jenkins-vpc"
vpc_cidr       = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24"]
instance_type  = "t3.medium"
jenkins_ec2_instance = "Jenkins-Build-Server"
jenkins_security_group = "jenkins-sg"
instance_ami  = "ami-03ca36368dbc9cfa1"
