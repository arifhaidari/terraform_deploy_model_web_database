# assiging variable 
# variable "aws_region" {
#   default = "eu-north-1"
# }

# variable "ami_id" {
#   default = "ami-0bc89781b6ac5abaa"
# }

# provider "aws" {
#   region = var.aws_region
# }
# there are so many providers as well for different platforms and we can develop our own provider as well.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# # an instance within EC2, the name is the_start
resource "aws_instance" "the_start" {
  #      # ami: an operating system - the Amazon Machine Image  containing full set of information
#      # required to create an EC2 virtual machine instance
#      # since I am in europe and I use AMI-ID in europe 
#   ami           = "ami-09f575c31e671ea75" # Ubuntu 20.04 LTS // eu-noth-1
  ami           = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t2.micro"
}