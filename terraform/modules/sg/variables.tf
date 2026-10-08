variable "aws_vpc" {
  type = string
}

variable "aws_sg" {
  type = object({
    name = string
  })
}


variable "ingress" {
  type = list(object({
    name        = string
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
}
