provider "aws" {
	region = var.region
    profile = var.profile
}

resource "aws_s3_bucket" "rds_data_bucket" {
    bucket = var.name // "rds_data_bucket"

    tags = {
        "Name" = var.name
    }
}

resource "aws_s3_bucket_acl" "rds_data_bucket_acl" {
    bucket = aws_s3_bucket.rds_data_bucket.id
    acl = "private"
}

output "s3_bucket" {
    value = aws_s3_bucket.rds_data_bucket.bucket
}