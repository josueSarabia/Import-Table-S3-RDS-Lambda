resource "aws_security_group" "postgresql_sg" {
  name        = "postgresql"
  description = "Open Postgres for incoming traffic"

  ingress = [{
    cidr_blocks = ["190.84.119.238/32"]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }, /* { lambda
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      security_groups = [ "value" ]
      self = true
    } */]
}

resource "aws_db_instance" "default" {
  db_name           = "postgres"
  identifier        = var.identifier
  engine            = "postgres"
  username          = "postgres"
  password          = var.password
	publicly_accessible = false
	instance_class = "db.t3.micro"
	storage_type = "gp2"
	iam_database_authentication_enabled = true
	skip_final_snapshot  = true
  allocated_storage = 10
	vpc_security_group_ids = [ aws_security_group.postgresql_sg.id ]
  
}

resource "aws_iam_policy" "policy" {
  name        = "rds-s3-import-policy"
  description = "rds-s3-import-policy"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "s3import",
			"Action": [
				"s3:GetObject",
				"s3:ListBucket"
			],
			"Effect": "Allow",
			"Resource": [
				"arn:aws:s3:::${var.s3_bucket}", 
				"arn:aws:s3:::${var.s3_bucket}/*"
			] 
		}
	] 
}
EOF
}

resource "aws_iam_role" "role" {
  name = "rds-s3-import-role"

  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "rds.amazonaws.com"
			},
			"Action": "sts:AssumeRole",
			"Condition": {
					"StringEquals": {
						"aws:SourceArn": "arn:aws:rds:${var.region}:${var.account_number}:db:${var.identifier}"
						}
					}
		}
	] 
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_db_instance_role_association" "rds_s3_role_association" {
  db_instance_identifier = var.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.role.arn
}
