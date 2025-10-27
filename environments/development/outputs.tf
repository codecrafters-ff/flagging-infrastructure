output "test_bucket_name" {
  value = aws_s3_bucket.dev_test_bucket.bucket
}

output "region" {
  value = var.aws_region
}