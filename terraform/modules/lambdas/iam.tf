data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---- Create Lambda role policy (Put + Get, optional collision check) ----
data "aws_iam_policy_document" "create_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem"
    ]
    resources = [var.ddb_table_arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "create_role" {
  name               = "${var.project_name}-create-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "create_inline" {
  name   = "${var.project_name}-create-inline"
  role   = aws_iam_role.create_role.id
  policy = data.aws_iam_policy_document.create_policy.json
}

# ---- Retrieve Lambda role policy (Get + Update hits) ----
data "aws_iam_policy_document" "retrieve_policy" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]
    resources = [var.ddb_table_arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "retrieve_role" {
  name               = "${var.project_name}-retrieve-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "retrieve_inline" {
  name   = "${var.project_name}-retrieve-inline"
  role   = aws_iam_role.retrieve_role.id
  policy = data.aws_iam_policy_document.retrieve_policy.json
}
