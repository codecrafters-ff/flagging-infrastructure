##############################################
# DEVELOPMENT ENVIRONMENT OUTPUTS
##############################################
output "region" {
  description = "Region where resources are deployed"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID for development environment"
  value       = module.network.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.compute.instance_public_ip
}

output "dev_test_bucket" {
  description = "S3 bucket name for dev test bucket"
  value       = aws_s3_bucket.dev_test_bucket.bucket
}

output "admin_key_arn" {
  description = "ARN of the admin key parameter in SSM"
  value       = module.secrets.admin_key_arn
}

output "elastic_ip" {
  description = "Elastic IP address associated with the EC2 instance"
  value       = aws_eip.dev_app.public_ip
}
