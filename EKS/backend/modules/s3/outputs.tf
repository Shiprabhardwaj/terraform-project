output "bucket_name" {
    value = aws_s3_bucket.statefile.bucket
}
output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform-lock.name
}