resource "aws_key_pair" "pub_key" {
  key_name   = "lokesh-key"
  public_key = file(var.key.public_key)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "server" {
  for_each                    = var.servers
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = each.value == "web" ? var.subnet_pub[0] : var.subnet_private[0]
  associate_public_ip_address = each.value == "web" ? true : false
  vpc_security_group_ids      = [var.aws_sg]
  key_name                    = aws_key_pair.pub_key.key_name
  iam_instance_profile        = var.iam_instance_profile
  tags = {
    Name = each.key
    Tier = each.value
  }
}
