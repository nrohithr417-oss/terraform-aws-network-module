########################################
# VPC
########################################

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

########################################
# Default Security Group
########################################

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ########################################
  # Remove all default ingress rules
  ########################################

  ingress = []

  ########################################
  # Remove all default egress rules
  ########################################

  egress = []

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-default-sg"
    }
  )
}