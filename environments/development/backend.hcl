bucket         = "flagging-infra-tf-state-code-crafters"
key            = "environments/development/terraform.tfstate"
region         = "af-south-1"
dynamodb_table = "flagging-infra-tf-locks"
encrypt        = true
