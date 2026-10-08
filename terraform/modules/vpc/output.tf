output "vpc" {
  value = aws_vpc.ansbile_vpc.id
}

output "igw" {
  value = aws_internet_gateway.ansbile_igw.id
}

output "subnet_pub" {
  value = aws_subnet.public_subnet[*].id
}

output "subnet_private" {
  value = aws_subnet.private_subnet[*].id
}
