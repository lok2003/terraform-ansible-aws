output "instance_id" {
  value = aws_instance.ansible.id
}

output "public_ip" {
  value = aws_instance.ansible.public_ip
}

output "private_ip" {
  value = aws_instance.ansible.private_ip
}

output "dns" {
  value = aws_instance.ansible.public_dns
}
