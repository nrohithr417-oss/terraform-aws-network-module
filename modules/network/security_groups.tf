########################################
# Public Security Group
########################################

resource "aws_security_group" "public" {

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

resource "aws_vpc_security_group_ingress_rule" "public_ssh" {

  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 22
  to_port   = 22

  ip_protocol = "tcp"

  description = "Allow SSH"
}

resource "aws_vpc_security_group_ingress_rule" "public_http" {

  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 80
  to_port   = 80

  ip_protocol = "tcp"

  description = "Allow HTTP"
}

resource "aws_vpc_security_group_ingress_rule" "public_https" {

  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = 443
  to_port   = 443

  ip_protocol = "tcp"

  description = "Allow HTTPS"
}

resource "aws_vpc_security_group_egress_rule" "public_all" {

  security_group_id = aws_security_group.public.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow All Outbound"
}

########################################
# Private Security Group
########################################

resource "aws_security_group" "private" {

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

resource "aws_vpc_security_group_ingress_rule" "private_internal" {

  security_group_id = aws_security_group.private.id

  cidr_ipv4 = var.vpc_cidr

  ip_protocol = "-1"

  description = "Allow VPC Traffic"
}

resource "aws_vpc_security_group_egress_rule" "private_all" {

  security_group_id = aws_security_group.private.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"

  description = "Allow All Outbound"
}