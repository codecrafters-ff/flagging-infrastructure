##############################################
# SECRETS MODULE OUTPUTS
# modules/secrets/outputs.tf
##############################################

output "admin_key_arn" {
  value = aws_ssm_parameter.admin_key.arn
}

output "sa_password_arn" {
  value = aws_ssm_parameter.sa_password.arn
}

output "redis_password_arn" {
  value = aws_ssm_parameter.redis_password.arn
}

output "ghcr_token_arn" {
  value = aws_ssm_parameter.ghcr_token.arn
}
