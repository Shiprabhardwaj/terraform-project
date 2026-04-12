provider "aws" {
     region = var.region
     version = "~> 3.0"
}

resource "aws_s3_bucket" "statefile" {
  bucket = var.bucket_name

#   lifecycle{
#     prevent_destroy = true
#   }

  tags = {
    Name        = "var.bucket_name"
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
    name = var.dynamodb_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
    attribute {
        name = "LockID"
        type = "S"
    }
}
