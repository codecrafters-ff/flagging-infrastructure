##############################################
# DEVELOPMENT ENVIRONMENT BACKEND
# env/dev/backend.hcl
##############################################

bucket         = "flagging-infra-tf-state-code-crafters"
key            = "environments/development/terraform.tfstate"
region         = "af-south-1"
use_lockfile   = true
encrypt        = true
