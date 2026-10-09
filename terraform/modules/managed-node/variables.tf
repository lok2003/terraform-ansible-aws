variable "aws_sg" {
  type = string
}

variable "subnet_pub" {
  type = list(string)
}

variable "subnet_private" {
  type = list(string)
}

variable "key" {
  type = object({
    key_name   = string
    public_key = optional(string, "~/.ssh/id_ed25519.pub")
  })
}

variable "iam_instance_profile" {
  type = string
}


variable "servers" {
  type = map(object({
    tier = string
    os   = string
  }))
  validation {
    condition = alltrue([
      for server in values(var.servers) :
      contains(["web", "app"], server.tier) && contains(["ubuntu", "amazon"], server.os)
    ])
    error_message = "Each server must have tier web or app, and os ubuntu or amazon"
  }
}


