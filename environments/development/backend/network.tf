##############################################
# DEVELOPMENT ENVIRONMENT NETWORK
# env/dev/network.tf
##############################################

module "network" {
  source               = "../../../modules/network"
  name                 = "ff-dev"
  environment          = "development"
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidr_a = "10.10.1.0/24"
  public_subnet_cidr_b = "10.10.2.0/24"
  az_a                 = "af-south-1a"
  az_b                 = "af-south-1b"
  allowed_api_cidrs    = var.allowed_api_cidrs
  allowed_ssh_cidrs    = var.allowed_ssh_cidrs
  allowed_cms_cidrs    = var.allowed_cms_cidrs
}
