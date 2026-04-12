output "bucket_name" {
    description = "The name of the S3 bucket used for Terraform state storage"
    value = module.backend.bucket_name
}
output "dynamodb_table_name" {
    description = "The name of the DynamoDB table used for Terraform state locking"
    value = module.backend.dynamodb_table_name
}
