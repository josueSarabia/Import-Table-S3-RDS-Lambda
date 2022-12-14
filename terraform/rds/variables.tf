variable "identifier" {
    description = "rds instance identifier"
}

variable "password" {
    description = "rds instance password"
}

variable "s3_bucket" {
    description = "s3 bucket to include in rds policy document"
}

variable "region" {
    description = "region that it is in the rds arn"
}

variable "account_number" {
    description = "account number that it is in the rds arn"
}

variable "profile" {
  description = "aws user profile"
}

variable "postgresql_sg_id" {
    description = "rds security group id"
}