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



resource "aws_network_acl_rule" "public_http_ingress" {

  network_acl_id = aws_network_acl.public.id



  rule_number = 100

  egress = false



  protocol = "tcp"

  rule_action = "allow"



  cidr_block = "0.0.0.0/0"



  from_port = 80

  to_port = 80

}



resource "aws_network_acl_rule" "public_https_ingress" {

  network_acl_id = aws_network_acl.public.id



  rule_number = 110

  egress = false



  protocol = "tcp"

  rule_action = "allow"



  cidr_block = "0.0.0.0/0"



  from_port = 443

  to_port = 443

}



resource "aws_network_acl_rule" "public_ssh_ingress" {

  network_acl_id = aws_network_acl.public.id



  rule_number = 120

  egress = false



  protocol = "tcp"

  rule_action = "allow"



  cidr_block = "0.0.0.0/0"



  from_port = 22

  to_port = 22

}



resource "aws_network_acl_rule" "public_egress" {

  network_acl_id = aws_network_acl.public.id



  rule_number = 100

  egress = true



  protocol = "-1"

  rule_action = "allow"



  cidr_block = "0.0.0.0/0"



  from_port = 0

  to_port = 0

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



resource "aws_network_acl_rule" "private_ingress" {

  network_acl_id = aws_network_acl.private.id



  rule_number = 100

  egress = false



  protocol = "-1"

  rule_action = "allow"



  cidr_block = var.vpc_cidr



  from_port = 0

  to_port = 0

}



resource "aws_network_acl_rule" "private_egress" {

  network_acl_id = aws_network_acl.private.id



  rule_number = 100

  egress = true



  protocol = "-1"

  rule_action = "allow"



  cidr_block = "0.0.0.0/0"



  from_port = 0

  to_port = 0

}