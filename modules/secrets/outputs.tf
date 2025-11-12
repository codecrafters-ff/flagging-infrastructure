##############################################
# SECRETS MODULE OUTPUTS
# modules/secrets/outputs.tf
##############################################

output "admin_key_arn" {
  description = "ARN of the Admin key parameter (if created)"
  value       = try(aws_ssm_parameter.admin_key[0].arn, null)
}

output "sa_password_arn" {
  description = "ARN of the SA password parameter (if created)"
  value       = try(aws_ssm_parameter.sa_password[0].arn, null)
}

output "redis_password_arn" {
  description = "ARN of the Redis password parameter (if created)"
  value       = try(aws_ssm_parameter.redis_password[0].arn, null)
}

output "ghcr_token_arn" {
  description = "ARN of the GHCR token parameter (if created)"
  value       = try(aws_ssm_parameter.ghcr_token[0].arn, null)
}
