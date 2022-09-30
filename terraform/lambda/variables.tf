variable "bucket_name" {
    description = "bucket name that triggers the lambda"
}

variable "secret_name" {
    description = "name of the rds password secret"
}

variable "rds_host" {
    description = "host that lambda is going to connect"
}
variable "region" {
    description = "region of the lambda"
}

variable "profile" {
    description = "aws user profile"
}