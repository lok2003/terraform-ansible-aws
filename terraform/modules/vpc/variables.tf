variable "aws_vpc" {
  type = object({
    name       = string
    cidr_block = string
  })
}

variable "subnet_pub" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}


variable "subnet_private" {
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}
