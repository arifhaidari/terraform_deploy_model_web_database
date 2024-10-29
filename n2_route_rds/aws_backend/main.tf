terraform {
  # Specify required provider configurations
  required_providers {
    aws = {
     # aws is the provider in this case
      source  = "hashicorp/aws"
      version = "~> 3.0" # Locks the AWS provider to version 3.x for compatibility
    }
  }
}

# variables for reusability and to avoid hardcoding values
variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "tf-state-store-mlops" # Replace with your desired bucket name
}

provider "aws" {
  # Define the AWS region; it can be overridden via environment variables or CLI arguments
  region = var.aws_region
#   region = "us-east-1" # to simple, we hard coded here
}

resource "aws_s3_bucket" "terraform_state" {
  # Creates an S3 bucket to store Terraform state
  bucket        = var.s3_bucket_name # Set bucket name via a variable for flexibility
#   bucket        = "tf-state-store-mlops"
  force_destroy = true # Forces deletion of non-empty bucket during Terraform destroy
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  # Enables versioning to retain prior versions of state files, for safer rollbacks
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  # Applies server-side encryption (AES256) to protect the state file in the S3 bucket
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  # Sets up a DynamoDB table for state locking to prevent simultaneous state modifications
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST" # Pay only for the capacity used
  hash_key     = "LockID" # Primary key for the lock record

  # Define table attribute for the LockID key
  attribute {
    name = "LockID"
    type = "S" # Specifies attribute type as String
  }
}


