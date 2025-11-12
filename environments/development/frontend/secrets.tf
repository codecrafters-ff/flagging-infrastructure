##############################################
# DEVELOPMENT ENVIRONMENT SECRETS
# eenv/dev/frontend/secrets.tf
##############################################

module "secrets" {
  source              = "../../../modules/secrets"
  backend_environment = "development"
  ghcr_token          = var.ghcr_token
}
