##############################################
# DEVELOPMENT ENVIRONMENT INFRASTRUCTURE
# env/dev/frontend/main.tf
##############################################

# S3 Bucket for Dev Testing
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "dev_test_bucket" {
  bucket = "ff-dev-frontend-test-bucket-${random_id.suffix.hex}"

  tags = {
    Name        = "DevFrontendTestBucket"
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}

resource "aws_eip" "dev_app" {
  instance = module.compute.instance_id
  domain   = "vpc"
  tags     = { Name = "ff-dev-frontend-eip" }
}
