provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "send traffic to rds postgresql"

  egress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "postgresql_sg" {
  name        = "postgresql_sg"
  description = "Open Postgres for incoming traffic"

  ingress {
    cidr_blocks = ["190.84.119.238/32"]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.name]
  }
}

output "postgresql_sg_id" {
  value = aws_security_group.postgresql_sg.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

