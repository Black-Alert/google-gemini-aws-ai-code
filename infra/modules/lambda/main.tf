resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  memory_size      = var.memory_size
  timeout          = var.timeout
  role             = var.role_arn
  s3_bucket        = var.bucket_id
  s3_key           = aws_s3_object.this.key
  runtime          = var.runtime
  handler          = var.handler
  source_code_hash = data.archive_file.this.output_base64sha256
  layers           = var.layers
  publish          = true
  # Enable X-Ray Tracing
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = var.lambda_env_vars
  }

  #   dynamic "dead_letter_config" {
  #     for_each = ""
  #     content {}
  #   }


  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }
}

resource "aws_s3_object" "this" {
  bucket = var.bucket_id

  key    = "${var.function_name}_${terraform.workspace}.zip"
  source = data.archive_file.this.output_path

  etag = filemd5(data.archive_file.this.output_path)
  lifecycle {
    ignore_changes = [etag]
  }
}

data "archive_file" "this" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda-code.zip"
}


resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 7
}

resource "aws_lambda_provisioned_concurrency_config" "this" {
  function_name                     = aws_lambda_function.this.function_name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  qualifier                         = aws_lambda_function.this.version
  depends_on = [aws_lambda_function.this]
  count                             = var.is_concurrent == true ? 1 : 0
}