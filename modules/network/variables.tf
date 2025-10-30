##############################################
# NETWORK MODULE VARIABLES
# modules/network/variables.tf
##############################################

variable "name" { type = string }
variable "environment" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_cidr_a" { type = string }
variable "public_subnet_cidr_b" { type = string }
variable "az_a" { type = string }
variable "az_b" { type = string }

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to SSH into EC2 (22)"
  default     = ["0.0.0.0/0"]
}

variable "allowed_api_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to reach API (8080)"
  default     = ["0.0.0.0/0"]
}
