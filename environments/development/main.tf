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

resource "aws_key_pair" "dev_admin" {
  key_name   = "ff-dev-admin"
  public_key = file("~/.ssh/ff-dev-admin.pub")
}

resource "aws_eip" "dev_app" {
  instance = module.compute.instance_id
  domain   = "vpc"
  tags     = { Name = "ff-dev-eip" }
}
