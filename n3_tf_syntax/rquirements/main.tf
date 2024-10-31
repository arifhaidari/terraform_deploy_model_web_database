terraform {
  backend "s3" {
    bucket         = "mlops-directive-tf-state"
    key            = "n3_tf_syntax/requirements/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

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

locals {
  extra_tag = "extra-tag"
}

resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "12"
  instance_class      = "db.t2.micro"
  name                = "mydb"
  username            = var.db_user
  password            = var.db_pass
  skip_final_snapshot = true
}
# since the following two variables are sensitvie we provide the values at run time 
# when we run the on the terminal 
# and when we define that variable as well then we put sensitive = true so it won't echo into the terminal
# and when to run it on terminal:
# terraform apply -var="db_user=my_user" -var="db_pass=some_secure_pass"
  # username            = var.db_user
  # password            = var.db_pass