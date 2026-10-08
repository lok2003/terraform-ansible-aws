variable "aws_sg" {
  type = string
}


variable "subnet_pub" {
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
