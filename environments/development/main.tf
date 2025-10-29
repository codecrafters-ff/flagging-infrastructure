##############################################
# DEVELOPMENT ENVIRONMENT INFRASTRUCTURE
##############################################

# S3 Bucket for Dev Testing
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "dev_test_bucket" {
  bucket = "ff-dev-test-bucket-${random_id.suffix.hex}"

  tags = {
    Name        = "DevTestBucket"
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}
