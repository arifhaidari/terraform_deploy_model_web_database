terraform {
  # Configuring the backend for Terraform state storage, using an S3 bucket and DynamoDB for state locking
  # Ensure the S3 bucket and DynamoDB table are pre-configured for proper state management.
  backend "s3" {
    bucket         = "tf-state-store-mlops"    # S3 bucket to store the state file
    key            = "n2_route_rds/web_app/terraform.tfstate" # State file path within the bucket
    region         = "us-east-1"                     # AWS region where S3 and DynamoDB reside
    dynamodb_table = "terraform-state-locking"       # DynamoDB table for state locking to prevent conflicts
    encrypt        = true                            # Enables encryption of the state file
  }

  # Specifies the required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"                      # AWS provider source
      version = "~> 3.0"                             # AWS provider version compatible with 3.x
    }
  }
}

provider "aws" {
  region = "us-east-1"                               # Default AWS region for resource deployment
}

resource "aws_instance" "instance_1" {
  # Creates an EC2 instance with Ubuntu 20.04 in 'us-east-1'
  ami             = "ami-011899242bb902164"         # AMI ID for Ubuntu 20.04 LTS in us-east-1
  instance_type   = "t2.micro"                      # Instance type (small for basic applications)
  security_groups = [aws_security_group.instances.name] # Assigns security group to the instance
  # Boot script to set up a simple HTTP server
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}

resource "aws_instance" "instance_2" {
  # Creates another EC2 instance with the same configuration
  ami             = "ami-011899242bb902164"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 2" > index.html
              python3 -m http.server 8080 &
              EOF
}

# this s3 bucket is not used but to show there are possibility that we
# can attach it to instances of EC2
resource "aws_s3_bucket" "bucket" {
  # Creates an S3 bucket with the specified prefix and sets it for forceful deletion
  bucket_prefix = "devops-directive-web-app-data"  # Prefix to generate unique bucket name
  force_destroy = true                             # Allows deletion even if non-empty
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  # Enables versioning on the S3 bucket for data recovery
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  # Configures server-side encryption for the S3 bucket to secure stored data
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"                      # Uses AES-256 for encryption
    }
  }
}

# in here as you can see that we have used data block instead of resource block becuase we are
# reference to existing blocks in AWS - as you can see they are default which measn they exist by default
data "aws_vpc" "default_vpc" {
  # Fetches details of the default VPC in the region
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  # Retrieves IDs of subnets within the default VPC
  vpc_id = data.aws_vpc.default_vpc.id
}

# security groups for allowing inbound traffic
resource "aws_security_group" "instances" {
  # Creates a security group for instances to control traffic
  name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  # Adds an inbound rule to allow HTTP traffic on port 8080 from all IPs
  type              = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]                      # Allows access from any IP
}

resource "aws_lb_listener" "http" {
  # Configures a listener on the Application Load Balancer for HTTP traffic
  load_balancer_arn = aws_lb.load_balancer.arn

  port = 80                                        # Listening on port 80 for HTTP

  protocol = "HTTP"                                # HTTP protocol

  # Sets a default 404 page for unhandled paths
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "instances" {
  # Defines a target group for load balancing to EC2 instances on port 8080
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {                                  # Health check configuration
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  # Attaches instance_1 to the target group for load balancing
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  # Attaches instance_2 to the target group for load balancing
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

resource "aws_lb_listener_rule" "instances" {
  # Sets listener rule for path-based routing on the load balancer
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]                              # Forwards all traffic
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_security_group" "alb" {
  # Security group for the Application Load Balancer (ALB)
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  # Allows inbound HTTP traffic to ALB on port 80 from any IP
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  # Allows all outbound traffic from the ALB to any destination
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "load_balancer" {
  # Defines an Application Load Balancer for web app traffic distribution
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_route53_zone" "primary" {
  # Creates a Route 53 hosted zone for DNS management
  name = "mlopspractice.com"
}

resource "aws_route53_record" "root" {
  # Creates a DNS A record to map domain name to ALB
  zone_id = aws_route53_zone.primary.zone_id
  name    = "mlopspractice.com"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

# right now we do not use this in our infrastructure
resource "aws_db_instance" "db_instance" {
  # Creates a PostgreSQL RDS instance with auto minor version upgrades
  allocated_storage = 20                         # Storage allocation in GB
  auto_minor_version_upgrade = true              # Allows minor version upgrades
  storage_type               = "standard"        # Standard storage
  engine                     = "postgres"        # Database engine
  engine_version             = "12"              # Major version
  instance_class             = "db.t2.micro"     # Instance class
  name                       = "mydb"            # Database name
  username                   = "foo"             # DB username
  password                   = "foobarbaz"       # DB password
  skip_final_snapshot        = true              # Skips final snapshot on deletion
}
