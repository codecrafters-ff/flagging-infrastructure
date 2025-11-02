##############################################
# SECRETS MODULE
# modules/secrets/main.tf
##############################################

resource "aws_ssm_parameter" "sa_password" {
  name  = "/ff/dev/SA_PASSWORD"
  type  = "SecureString"
  value = var.sa_password
}

resource "aws_ssm_parameter" "admin_key" {
  name  = "/ff/dev/ADMIN_KEY"
  type  = "SecureString"
  value = var.admin_key
}

resource "aws_ssm_parameter" "redis_password" {
  name  = "/ff/dev/REDIS_PASSWORD"
  type  = "SecureString"
  value = var.redis_password
}

resource "aws_ssm_parameter" "ghcr_token" {
  name  = "/ff/dev/GHCR_PAT"
  type  = "SecureString"
  value = var.ghcr_token
}
