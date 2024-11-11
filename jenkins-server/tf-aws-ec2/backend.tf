provider "aws" {
    region = var.aws_region
    assume_role {
         role_arn = var.DEPLOY_ROLE
     }  
}

terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 3.29.0"
    }
  }
    backend "s3" {
        bucket = "palm-cicd-artifact"
        key = "eks-jenkins/terraform.tfstate"
        dynamodb_table = "palm-terraform-locks"
        kms_key_id     = "arn:aws:kms:eu-west-1:038462750799:key/fbfc32d6-539b-4c81-bf58-d5db169b5322"
        region = "eu-west-1"
    }
}

data "terraform_remote_state" "aws-cicd" {
    backend = "s3"

    config = {
      bucket = "palm-terraform-remote-state"
      key = "palm-cicd/terraform.tfstate"
      region = "eu-west-1"
    }
}
