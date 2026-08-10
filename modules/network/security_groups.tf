########################################
# Public Security Group
########################################

resource "aws_security_group" "public" {
  #checkov:skip=CKV2_AWS_5:Reusable network module exports this security group for attachment by downstream ALB or compute modules.

  name        = "${local.name_prefix}-public-sg"
  description = "Public Security Group"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-sg"
    }
  )
}

########################################
# Public Security Group - HTTP
########################################

resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4 = var.vpc_cidr

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"

  description = "Allow HTTP traffic from within the VPC"
}

########################################
# Public Security Group - HTTPS
########################################

resource "aws_vpc_security_group_ingress_rule" "public_https" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"

  description = "Allow HTTPS traffic"
}

########################################
# Public Security Group - Egress
########################################

resource "aws_vpc_security_group_egress_rule" "public_all" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}

########################################
# Private Security Group
########################################

resource "aws_security_group" "private" {
  #checkov:skip=CKV2_AWS_5:Reusable network module exports this security group for attachment by downstream EC2 or Auto Scaling resources.

  name        = "${local.name_prefix}-private-sg"
  description = "Private Security Group"
  vpc_id      = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-sg"
    }
  )
}

########################################
# Private Security Group - HTTP
########################################

resource "aws_vpc_security_group_ingress_rule" "private_http" {
  security_group_id = aws_security_group.private.id

  cidr_ipv4 = var.vpc_cidr

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"

  description = "Allow HTTP traffic from within the VPC"
}

########################################
# Private Security Group - HTTPS
########################################

resource "aws_vpc_security_group_ingress_rule" "private_https" {
  security_group_id = aws_security_group.private.id

  referenced_security_group_id = aws_security_group.public.id

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"

  description = "Allow HTTPS traffic from the public security group"
}

########################################
# Private Security Group - Egress
########################################

resource "aws_vpc_security_group_egress_rule" "private_all" {
  security_group_id = aws_security_group.private.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow all outbound traffic"
}