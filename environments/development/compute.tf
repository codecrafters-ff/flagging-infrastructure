module "compute" {
  source            = "../../modules/compute-ec2"
  name_prefix       = "ff-dev"
  environment       = "development"
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.host_sg_id
  key_name          = aws_key_pair.dev_admin.key_name
}
