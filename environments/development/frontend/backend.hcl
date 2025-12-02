##############################################
# DEVELOPMENT ENVIRONMENT BACKEND
# env/dev/frontend/backend.hcl
##############################################

bucket         = "flagging-infra-tf-state-code-crafters"
dynamodb_table = "flagging-infra-tf-locks"
key            = "environments/development/frontend/terraform.tfstate"
region         = "af-south-1"
use_lockfile   = true
encrypt        = true
