########################################
# VPC Endpoint - S3 (Gateway)
########################################

resource "aws_vpc_endpoint" "s3" {

  count = var.enable_endpoints ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [
      for rt in aws_route_table.private :
      rt.id
    ]
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-s3-endpoint"
    }
  )
}

########################################
# VPC Endpoint - DynamoDB (Gateway)
########################################

resource "aws_vpc_endpoint" "dynamodb" {

  count = var.enable_endpoints ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [
      for rt in aws_route_table.private :
      rt.id
    ]
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-dynamodb-endpoint"
    }
  )
}

########################################
# VPC Endpoint - SSM (Interface)
########################################

resource "aws_vpc_endpoint" "ssm" {

  count = var.enable_endpoints ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    for key, subnet in aws_subnet.this :
    subnet.id
    if startswith(key, "private-")
  ]

  security_group_ids = [
    aws_security_group.private.id
  ]

  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-ssm-endpoint"
    }
  )
}