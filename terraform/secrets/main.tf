
resource "aws_secretsmanager_secret" "rds_password" {
  name = var.name # "rds_password"
  replica {
    region = var.region
  }
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
    secret_id = aws_secretsmanager_secret.rds_password.id
    secret_string = var.value
}