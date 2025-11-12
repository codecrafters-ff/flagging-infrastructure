##############################################
# DEVELOPMENT ENVIRONMENT NETWORK
# env/dev/frontend/network.tf
##############################################

module "network" {
  source               = "../../../modules/network"
  name                 = "ff-dev-frontend"
  environment          = "development"
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidr_a = "10.10.1.0/24"
  public_subnet_cidr_b = "10.10.2.0/24"
  az_a                 = "af-south-1a"
  az_b                 = "af-south-1b"
  allowed_api_cidrs    = var.allowed_api_cidrs
}
