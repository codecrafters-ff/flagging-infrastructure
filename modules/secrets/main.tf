##############################################
# SECRETS MODULE
# modules/secrets/main.tf
##############################################

resource "aws_ssm_parameter" "sa_password" {
  count     = var.sa_password == null ? 0 : 1
  name      = "/ff/dev/SA_PASSWORD"
  type      = "SecureString"
  value     = var.sa_password
  overwrite = true
  tags = {
    Environment = var.backend_environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "admin_key" {
  count     = var.admin_key == null ? 0 : 1
  name      = "/ff/dev/ADMIN_KEY"
  type      = "SecureString"
  value     = var.admin_key
  overwrite = true
  tags = {
    Environment = var.backend_environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "redis_password" {
  count     = var.redis_password == null ? 0 : 1
  name      = "/ff/dev/REDIS_PASSWORD"
  type      = "SecureString"
  value     = var.redis_password
  overwrite = true
  tags = {
    Environment = var.backend_environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "ghcr_token" {
  count     = var.ghcr_token == null ? 0 : 1
  name      = "/ff/dev/GHCR_PAT"
  type      = "SecureString"
  value     = var.ghcr_token
  overwrite = true
  tags = {
    Environment = var.backend_environment
    ManagedBy   = "Terraform"
  }
}

output "ghcr_token_arn" {
  value       = try(aws_ssm_parameter.ghcr_token[0].arn, null)
  description = "ARN of GHCR PAT if created"
}
