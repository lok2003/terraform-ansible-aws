module "vpc" {
  source         = "./modules/vpc"
  aws_vpc        = var.aws_vpc
  subnet_pub     = var.subnet_pub
  subnet_private = var.subnet_private
}

module "sg" {
  source  = "./modules/sg"
  aws_vpc = module.vpc.vpc
  ingress = var.ingress
  aws_sg  = var.aws_sg
}

module "iam" {
  source = "./modules/iam"
}


module "control-node" {
  source     = "./modules/control-node"
  aws_sg     = module.sg.sg_id
  subnet_pub = module.vpc.subnet_pub
  key = {
    key_name   = var.key.key_name
    public_key = var.key.public_key
  }
  iam_instance_profile = module.iam.instance_profile_name
}

module "managed-node" {
  source               = "./modules/managed-node"
  aws_sg               = module.sg.sg_id
  subnet_pub           = module.vpc.subnet_pub
  subnet_private       = module.vpc.subnet_private
  iam_instance_profile = module.iam.instance_profile_name
  key = {
    key_name   = "ansible-key"
    public_key = "~/.ssh/id_ed25519.pub"
  }
  servers = var.servers
}
