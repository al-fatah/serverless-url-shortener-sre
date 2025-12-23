resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# -------------------------
# Lambda: Create Errors
# -------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_create_errors" {
  alarm_name          = "${var.project_name}-lambda-create-errors"
  alarm_description   = "Create Lambda error count >= threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = var.alarm_period
  threshold           = var.alarm_threshold
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"

  dimensions = {
    FunctionName = var.create_lambda_function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# -------------------------
# Lambda: Retrieve Errors
# -------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_retrieve_errors" {
  alarm_name          = "${var.project_name}-lambda-retrieve-errors"
  alarm_description   = "Retrieve Lambda error count >= threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = var.alarm_period
  threshold           = var.alarm_threshold
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/Lambda"
  metric_name = "Errors"

  dimensions = {
    FunctionName = var.retrieve_lambda_function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# -------------------------
# API Gateway: 5XX Errors
# REST API metrics use namespace AWS/ApiGateway
# -------------------------
resource "aws_cloudwatch_metric_alarm" "apigw_5xx" {
  alarm_name          = "${var.project_name}-apigw-5xx"
  alarm_description   = "API Gateway 5XX errors >= threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = var.alarm_period
  threshold           = var.alarm_threshold
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  namespace   = "AWS/ApiGateway"
  metric_name = "5XXError"

  dimensions = {
    ApiName = var.apigw_api_name
    Stage   = var.apigw_stage_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
