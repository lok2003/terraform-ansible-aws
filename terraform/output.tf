output "vpc" {
  value = module.vpc
}

output "public_subnets" {
  value = module.vpc.subnet_pub
}

output "private_subnet" {
  value = module.vpc.subnet_private
}

output "sg" {
  value = module.sg
}

output "iam" {
  value = module.iam
}


output "control-node_instance_id" {
  value = module.control-node.instance_id
}

output "control-node_public_ip" {
  value = module.control-node.public_ip
}

output "control-node_private_ip" {
  value = module.control-node.private_ip
}

output "control-node_dns" {
  value = module.control-node.dns
}
output "instance_profile" {
  value = module.iam.instance_profile_name
}



output "managed_node_private_ips" {
  value = module.managed-node.private_ip
}

output "managed_node_public_ips" {
  value = module.managed-node.public_ip
}

output "managed_node_instance_ids" {
  value = module.managed-node.instance_id
}

output "managed_node_dns" {
  value = module.managed-node.dns
}
