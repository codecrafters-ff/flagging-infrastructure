##############################################
# DEVELOPMENT ENVIRONMENT OUTPUTS
# env/dev/frontend/outputs.tf
##############################################
output "dev_frontend_region" {
  description = "Region where resources are deployed"
  value       = var.aws_region
}

output "dev_frontend_vpc_id" {
  description = "VPC ID for development environment"
  value       = module.network.vpc_id
}

output "dev_frontend_public_subnets" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "dev_frontend_instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.compute.instance_public_ip
}

output "dev_frontend_test_bucket" {
  description = "S3 bucket name for dev frontend test bucket"
  value       = aws_s3_bucket.dev_test_bucket.bucket
}

output "dev_frontend_ghcr_token_arn" {
  description = "GHCR Token parameter in SSM"
  value       = module.secrets.ghcr_token_arn
}
output "dev_frontend_elastic_ip" {
  description = "Elastic IP address associated with the EC2 instance"
  value       = aws_eip.dev_app.public_ip
}
