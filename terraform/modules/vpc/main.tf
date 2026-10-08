resource "aws_vpc" "ansbile_vpc" {
  cidr_block = var.aws_vpc.cidr_block
  tags = {
    Name : var.aws_vpc.name
  }
}

resource "aws_internet_gateway" "ansbile_igw" {
  vpc_id = aws_vpc.ansbile_vpc.id
  tags = {
    Name : "ansible-Internet-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ansbile_vpc.id
  tags = {
    Name : "ansible-route-pub"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ansbile_vpc.id
  tags = {
    Name : "ansible-route-private"
  }
}

resource "aws_route" "igw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.ansbile_igw.id
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.subnet_pub)
  vpc_id                  = aws_vpc.ansbile_vpc.id
  cidr_block              = var.subnet_pub[count.index].cidr_block
  availability_zone       = var.subnet_pub[count.index].availability_zone
  map_public_ip_on_launch = var.subnet_pub[count.index].map_public_ip_on_launch
  tags = {
    Name = var.subnet_pub[count.index].name
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.subnet_private)
  vpc_id                  = aws_vpc.ansbile_vpc.id
  cidr_block              = var.subnet_private[count.index].cidr_block
  availability_zone       = var.subnet_private[count.index].availability_zone
  map_public_ip_on_launch = var.subnet_private[count.index].map_public_ip_on_launch
  tags = {
    Name = var.subnet_private[count.index].name
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnet_pub)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.subnet_private)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[1].id
  depends_on    = [aws_internet_gateway.ansbile_igw]
  tags = {
    Name = "ansible-nat"
  }
}

resource "aws_route" "nat_route" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  route_table_id         = aws_route_table.private.id
}
