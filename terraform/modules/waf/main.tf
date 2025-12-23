resource "aws_wafv2_ip_set" "allowlist" {
  name               = "${var.project_name}-allowlist"
  description        = "Allowed client IPs"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ips
}

resource "aws_wafv2_web_acl" "this" {
  name        = "${var.project_name}-webacl"
  description = "Allowlist-only WAF for API Gateway"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "AllowListedIPs"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allowlist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-allowlist"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-webacl"
    sampled_requests_enabled   = true
  }
}

# Associate Web ACL to API Gateway stage
resource "aws_wafv2_web_acl_association" "apigw" {
  resource_arn = var.apigw_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# WAF logs go to CloudWatch Log Group
resource "aws_cloudwatch_log_group" "waf" {
  # WAF logging requires this prefix
  name              = "aws-waf-logs-${var.project_name}"
  retention_in_days = 7
}

# IMPORTANT: WAF log delivery requires this resource policy on the log group.
data "aws_iam_policy_document" "cwlogs_waf_policy" {
  statement {
    sid     = "AWSWAFLogsToCloudWatch"
    effect  = "Allow"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    resources = ["${aws_cloudwatch_log_group.waf.arn}:*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  policy_name     = "${var.project_name}-waf-log-policy"
  policy_document = data.aws_iam_policy_document.cwlogs_waf_policy.json
}

# Log only BLOCK actions
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
    }
  }

  depends_on = [aws_cloudwatch_log_resource_policy.waf]
}
