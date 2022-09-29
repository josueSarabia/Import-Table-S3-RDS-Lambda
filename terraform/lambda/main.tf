data "archive_file" "layer_zip" {
    type = "zip"
    source_dir = "${path.module}/python/"
    output_path = "${path.module}/python/packages.zip"
}

resource "aws_lambda_layer_version" "python_dep_layer" {
  filename   = "${path.module}/python/packages.zip"
  layer_name = "python_dep_layer"

  compatible_runtimes = ["python3.8"]
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "layer_zip" {
    type = "zip"
    source_dir = "${path.module}/src/"
    output_path = "${path.module}/src/index.zip"
}

resource "aws_lambda_function" "import_table_lambda" {
  filename      = "${path.module}/src/index.zip"
  function_name = "import_table_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/src/index.zip")
  runtime = "python3.8"
  layers = [ aws_lambda_layer_version.python_dep_layer.arn ]
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = var.bucket_id
  lambda_function {
    lambda_function_arn = aws_lambda_function.import_table_lambda.arn
    events = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "test" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.import_table_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_id}"
}