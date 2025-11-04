##############################################
# COMPUTE (EC2) MODULE VARIABLES
# modules/compute-ec2/variables.tf
##############################################

variable "name_prefix" {
  description = "Prefix used for naming resources (e.g., ff-dev)"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., development, staging, production)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for compute environment"
  type        = string
  default     = "t3.medium"
}

variable "subnet_ids" {
  description = "List of subnet IDs for placing the EC2 instance"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}

variable "user_data_script" {
  description = "User data script for EC2 instance initialization"
  type        = string
  default     = ""
}
