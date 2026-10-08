output "instance_id" {
  value = {
    for name, instance in aws_instance.server :
    name => instance.id
  }
}

output "public_ip" {
  value = {
    for name, instance in aws_instance.server :
    name => instance.public_ip
  }
}

output "private_ip" {
  value = {
    for name, instance in aws_instance.server :
    name => instance.private_ip
  }
}

output "dns" {
  value = {
    for name, instance in aws_instance.server :
    name => instance.public_dns
  }
}
