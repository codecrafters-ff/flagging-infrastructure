variable "aws_region" {
  type    = string
  default = "af-south-1"
}

variable "state_bucket_name" {
  type    = string
  default = "flagging-infra-tf-state-code-crafters"
}

variable "lock_table_name" {
  type    = string
  default = "flagging-infra-tf-locks"
}