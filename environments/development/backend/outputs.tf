##############################################
# DEVELOPMENT ENVIRONMENT OUTPUTS
# env/dev/outputs.tf
##############################################
output "dev_backend_region" {
  description = "Region where resources are deployed"
  value       = var.aws_region
}

output "dev_backend_vpc_id" {
  description = "VPC ID for development environment"
  value       = module.network.vpc_id
}

output "dev_backend_public_subnets" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "dev_backend_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.compute.instance_public_ip
}

output "dev_backend_dev_test_bucket" {
  description = "S3 bucket name for dev test bucket"
  value       = aws_s3_bucket.dev_test_bucket.bucket
}

output "dev_backend_admin_key_arn" {
  description = "ARN of the admin key parameter in SSM"
  value       = module.secrets.admin_key_arn
}

output "dev_backend_sa_password" {
  description = "SA password parameter in SSM"
  value       = module.secrets.sa_password_arn
}

output "dev_backend_redis_password_arn" {
  description = "Redis password parameter in SSM"
  value       = module.secrets.redis_password_arn
}

output "dev_backend_ghcr_token_arn" {
  description = "GHCR Token parameter in SSM"
  value       = module.secrets.ghcr_token_arn
}
output "dev_backend_elastic_ip" {
  description = "Elastic IP address associated with the EC2 instance"
  value       = aws_eip.dev_app.public_ip
}
