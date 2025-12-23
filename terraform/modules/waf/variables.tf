variable "project_name" {
  type = string
}

variable "allowed_ips" {
  type        = list(string)
  description = "List of allowed CIDRs, e.g. [\"180.74.226.47/32\"]"
}

variable "apigw_stage_arn" {
  type        = string
  description = "API Gateway stage ARN to associate with WAF"
}

