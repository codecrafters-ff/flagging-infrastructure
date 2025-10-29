##############################################
# SECRETS MODULE OUTPUTS
##############################################

output "admin_key_arn" {
	value = aws_ssm_parameter.admin_key.arn
}
