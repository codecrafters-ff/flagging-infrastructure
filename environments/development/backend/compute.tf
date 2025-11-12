##############################################
# DEVELOPMENT ENVIRONMENT OUTPUTS
# env/dev/compute.tf
##############################################
module "compute" {
  source            = "../../../modules/compute-ec2"
  name_prefix       = "ff-dev"
  environment       = "development"
  environment_type  = "frontend"
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.host_sg_id
  key_name          = "ff-dev-admin"
  create_key_pair   = true
}
