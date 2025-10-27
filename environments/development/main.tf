resource "aws_s3_bucket" "dev_test_bucket" {
  bucket = "flagging-api-dev-${random_id.suffix.hex}"
  tags = {
    Name        = "DevTestBucket"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
