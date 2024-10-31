# Data source to fetch the default VPC in the AWS account.
data "aws_vpc" "default_vpc" {
  default = true  # Specifies that the default VPC should be used.
}

# Data source to fetch all subnet IDs within the default VPC.
data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id  # Uses the VPC ID from the default VPC data source.
}

# Creates a security group for instances, allowing control over network access.
resource "aws_security_group" "instances" {
  name = "${var.app_name}-${var.environment_name}-instance-security-group"
  # Security group name includes the application and environment for easier identification.
}

# Creates a security group rule to allow HTTP (port 8080) inbound traffic to instances.
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"                         # Specifies an inbound rule.
  security_group_id = aws_security_group.instances.id   # Associates the rule with the instance security group.

  from_port   = 8080          # Allow traffic from port 8080.
  to_port     = 8080          # Allow traffic to port 8080.
  protocol    = "tcp"         # Uses TCP protocol.
  cidr_blocks = ["0.0.0.0/0"] # Open to all IPs; caution: allows public access.
}

# Configures an HTTP listener for the load balancer to listen on port 80.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn  # Associates listener with the specified load balancer.

  port     = 80       # Port on which the listener listens for incoming traffic.
  protocol = "HTTP"   # HTTP protocol.

  # Default action for unmatched paths, returning a 404 response.
  default_action {
    type = "fixed-response"   # Sends a fixed response if the path does not match any rules.

    fixed_response {
      content_type = "text/plain"         # Response content type.
      message_body = "404: page not found" # Message returned for unmatched requests.
      status_code  = 404                  # HTTP 404 Not Found status.
    }
  }
}

# Defines a target group to route traffic to instance targets on port 8080.
resource "aws_lb_target_group" "instances" {
  name     = "${var.app_name}-${var.environment_name}-tg"  # Target group name.
  port     = 8080              # Routes traffic to port 8080 on instances.
  protocol = "HTTP"            # Uses HTTP protocol.
  vpc_id   = data.aws_vpc.default_vpc.id  # Associates the target group with the default VPC.

  # Health check configuration to verify instance health.
  health_check {
    path                = "/"         # Path used for health check requests.
    protocol            = "HTTP"      # HTTP protocol for health checks.
    matcher             = "200"       # Health check succeeds if HTTP 200 response is returned.
    interval            = 15          # Health check interval in seconds.
    timeout             = 3           # Timeout in seconds for health check response.
    healthy_threshold   = 2           # Number of successful checks to mark target as healthy.
    unhealthy_threshold = 2           # Number of failed checks to mark target as unhealthy.
  }
}

# Attaches an instance to the target group as a load balancer target.
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn  # Associates the attachment with the target group.
  target_id        = aws_instance.instance_1.id         # ID of the instance to attach.
  port             = 8080                               # Port to route traffic to on the instance.
}

# Attaches another instance to the target group.
resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

# Defines a listener rule to forward requests to the target group.
resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn  # Associates the rule with the HTTP listener.
  priority     = 100                       # Priority for rule evaluation; lower number is higher priority.

  # Matches any path pattern to forward traffic to the target group.
  condition {
    path_pattern {
      values = ["*"]  # Wildcard to match all paths.
    }
  }

  # Forwards matching requests to the specified target group.
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

# Creates a security group specifically for the Application Load Balancer (ALB).
resource "aws_security_group" "alb" {
  name = "${var.app_name}-${var.environment_name}-alb-security-group"
}

# Allows HTTP (port 80) inbound traffic to the ALB security group.
resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"                      # Inbound rule.
  security_group_id = aws_security_group.alb.id      # Associates rule with ALB security group.

  from_port   = 80           # Allow traffic from port 80.
  to_port     = 80           # Allow traffic to port 80.
  protocol    = "tcp"        # Uses TCP protocol.
  cidr_blocks = ["0.0.0.0/0"] # Open to all IPs, publicly accessible.
}

# Allows unrestricted outbound traffic from the ALB.
resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"                      # Outbound rule.
  security_group_id = aws_security_group.alb.id     # Associates rule with ALB security group.

  from_port   = 0              # Allows all ports.
  to_port     = 0              # Allows all ports.
  protocol    = "-1"           # "-1" for all protocols.
  cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs.
}

# Creates an Application Load Balancer (ALB) for handling web traffic.
resource "aws_lb" "load_balancer" {
  name               = "${var.app_name}-${var.environment_name}-web-app-lb" # Load balancer name.
  load_balancer_type = "application"                                        # Application load balancer.
  subnets            = data.aws_subnet_ids.default_subnet.ids               # Deploys in subnets of default VPC.
  security_groups    = [aws_security_group.alb.id]                          # Associates ALB security group.
}
