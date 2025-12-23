resource "aws_lambda_function" "create" {
  function_name = "${var.project_name}-create"
  role          = aws_iam_role.create_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"

  filename         = var.create_zip_path
  source_code_hash = filebase64sha256(var.create_zip_path)

  environment {
    variables = {
      APP_URL    = var.app_url
      REGION_AWS = var.region
      DB_NAME    = var.ddb_table_name
      MIN_CHAR   = "12"
      MAX_CHAR   = "16"
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_function" "retrieve" {
  function_name = "${var.project_name}-retrieve"
  role          = aws_iam_role.retrieve_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.12"

  filename         = var.retrieve_zip_path
  source_code_hash = filebase64sha256(var.retrieve_zip_path)

  environment {
    variables = {
      REGION_AWS = var.region
      DB_NAME    = var.ddb_table_name
    }
  }

  tracing_config {
    mode = "Active"
  }
}
