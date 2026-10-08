resource "aws_security_group" "ansible_sg" {
  vpc_id = var.aws_vpc
  name   = var.aws_sg.name

}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  security_group_id = aws_security_group.ansible_sg.id
  count             = length(var.ingress)
  from_port         = var.ingress[count.index].from_port
  to_port           = var.ingress[count.index].to_port
  ip_protocol       = var.ingress[count.index].ip_protocol
  cidr_ipv4         = var.ingress[count.index].cidr_ipv4
}
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.ansible_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
