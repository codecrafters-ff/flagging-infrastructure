##############################################
# COMPUTE (EC2) MODULE OUTPUTS
# modules/compute-ec2/outputs.tf
##############################################

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_ami_id" {
  description = "The AMI ID used for this EC2 instance"
  value       = data.aws_ami.al2023.id
}

output "iam_role_name" {
  description = "IAM Role name attached to the EC2 instance"
  value       = aws_iam_role.ec2_role.name
}

output "instance_profile_name" {
  description = "Instance profile name for EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}
