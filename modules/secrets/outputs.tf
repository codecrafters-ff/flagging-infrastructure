##############################################
# SECRETS MODULE OUTPUTS
# modules/secrets/outputs.tf
##############################################

output "admin_key_arn" {
  value = aws_ssm_parameter.admin_key.arn
}
