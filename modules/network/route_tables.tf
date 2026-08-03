########################################
# Public Route Table
########################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

resource "aws_route" "public_internet_access" {

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id
}

########################################
# Private Route Tables
########################################

resource "aws_route_table" "private" {

  count = var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${count.index + 1}"
    }
  )
}

resource "aws_route" "private_nat_access" {

  count = var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
}

########################################
# Public Route Table Associations
########################################

resource "aws_route_table_association" "public" {

  for_each = {
    for key, subnet in aws_subnet.this :
    key => subnet
    if startswith(key, "public-")
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

########################################
# Private Route Table Associations
########################################

resource "aws_route_table_association" "private" {

  for_each = {
    for key, subnet in aws_subnet.this :
    key => subnet
    if startswith(key, "private-")
  }

  subnet_id = each.value.id

  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[tonumber(split("-", each.key)[1])].id
}