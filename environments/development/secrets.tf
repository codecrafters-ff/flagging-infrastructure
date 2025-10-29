##############################################
# DEVELOPMENT ENVIRONMENT SECRETS
##############################################

module "secrets" {
  source         = "../../modules/secrets"
  sa_password    = var.sa_password
  admin_key      = var.admin_key
  redis_password = var.redis_password
}
