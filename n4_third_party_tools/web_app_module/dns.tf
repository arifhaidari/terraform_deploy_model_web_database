# Creates a Route 53 DNS zone if 'create_dns_zone' is true. 
# Sets up a public or private DNS zone depending on the variable 'domain'.
resource "aws_route53_zone" "primary" {
  count = var.create_dns_zone ? 1 : 0     # Conditionally create DNS zone based on 'create_dns_zone' variable.
  name  = var.domain                      # Domain name for the Route 53 hosted zone.
}

# Fetches an existing Route 53 DNS zone if 'create_dns_zone' is false. 
# Assumes a DNS zone with the specified 'domain' name already exists.
data "aws_route53_zone" "primary" {
  count = var.create_dns_zone ? 0 : 1     # Conditionally look up DNS zone if 'create_dns_zone' is false.
  name  = var.domain                      # Domain name to search for an existing Route 53 hosted zone.
}

# Defines local values to manage DNS settings.
locals {
  dns_zone_id = var.create_dns_zone ? aws_route53_zone.primary[0].zone_id : data.aws_route53_zone.primary[0].zone_id
  # The DNS zone ID to use, either from a newly created DNS zone or an existing one.

  subdomain = var.environment_name == "production" ? "" : "${var.environment_name}."
  # Sets the subdomain prefix. Uses an empty prefix for production, or appends environment name for non-production.
}

# Creates an A record in Route 53 for the root domain or environment-specific subdomain.
resource "aws_route53_record" "root" {
  zone_id = local.dns_zone_id                  # Uses the zone ID from either the new or existing DNS zone.
  name    = "${local.subdomain}${var.domain}"  # Sets the domain name, with or without a subdomain prefix.
  type    = "A"                                # A record for pointing to an IP address or load balancer alias.

  # Configures an alias record to an Application Load Balancer (ALB) endpoint.
  alias {
    name                   = aws_lb.load_balancer.dns_name       # DNS name of the ALB.
    zone_id                = aws_lb.load_balancer.zone_id        # Zone ID of the ALB.
    evaluate_target_health = true                                # Enables health checks for load balancing.
  }
}
