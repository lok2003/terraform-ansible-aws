variable "region" {
  type = string
}

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

variable "key" {
  type = object({
    key_name   = string
    public_key = optional(string, "~/.ssh/id_ed25519.pub")
  })
}

variable "servers" {
  type = map(object({
    tier = string
    os   = string
  }))

  default = {
    web-ubuntu = {
      tier = "web"
      os   = "ubuntu"
    }

    app-ubuntu = {
      tier = "app"
      os   = "ubuntu"
    }

    web-amazon = {
      tier = "web"
      os   = "amazon"
    }
  }
}
