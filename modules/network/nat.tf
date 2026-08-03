########################################
# Elastic IP
########################################

resource "aws_eip" "nat" {

  count = var.single_nat_gateway ? 1 : length(local.public_subnets)

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
  )
}

########################################
# NAT Gateway
########################################

resource "aws_nat_gateway" "this" {

  count = var.single_nat_gateway ? 1 : length(local.public_subnets)

  allocation_id = aws_eip.nat[count.index].id

  subnet_id = values({
    for key, subnet in aws_subnet.this :
    key => subnet
    if startswith(key, "public-")
  })[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${count.index + 1}"
    }
  )

  depends_on = [
    aws_internet_gateway.this
  ]
}