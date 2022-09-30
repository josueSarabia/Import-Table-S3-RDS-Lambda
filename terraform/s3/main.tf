provider "aws" {
	region = var.region
    profile = var.profile
}

resource "aws_s3_bucket" "rds_data_bucket" {
    bucket = var.name

    tags = {
        "Name" = var.name
    }
}

resource "aws_s3_bucket_acl" "rds_data_bucket_acl" {
    bucket = aws_s3_bucket.rds_data_bucket.id
    acl = "private"
}