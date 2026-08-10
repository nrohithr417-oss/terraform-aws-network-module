########################################
# Public Network ACL
########################################

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.this.id

  subnet_ids = [
    for key, subnet in aws_subnet.this :
    subnet.id
    if startswith(key, "public-")
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-nacl"
    }
  )
}

########################################
# Public NACL - HTTP Ingress
########################################

resource "aws_network_acl_rule" "public_http_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 80
  to_port   = 80
}

########################################
# Public NACL - HTTPS Ingress
########################################

resource "aws_network_acl_rule" "public_https_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 110
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 443
  to_port   = 443
}

########################################
# Public NACL - Ephemeral Ingress
########################################

resource "aws_network_acl_rule" "public_ephemeral_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 120
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = 1024
  to_port   = 65535
}

########################################
# Public NACL - Egress
########################################

resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = true

  protocol    = "-1"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 0
  to_port   = 0
}

########################################
# Private Network ACL
########################################

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  subnet_ids = [
    for key, subnet in aws_subnet.this :
    subnet.id
    if startswith(key, "private-")
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-nacl"
    }
  )
}

########################################
# Private NACL - HTTP Ingress
########################################

resource "aws_network_acl_rule" "private_http_ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = 80
  to_port   = 80
}

########################################
# Private NACL - HTTPS Ingress
########################################

resource "aws_network_acl_rule" "private_https_ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 110
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = 443
  to_port   = 443
}

########################################
# Private NACL - Ephemeral Ingress
########################################

resource "aws_network_acl_rule" "private_ephemeral_ingress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 120
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = 1024
  to_port   = 65535
}

########################################
# Private NACL - Egress
########################################

resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = aws_network_acl.private.id

  rule_number = 100
  egress      = true

  protocol    = "-1"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 0
  to_port   = 0
}