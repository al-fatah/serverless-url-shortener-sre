variable "domain_name" {
  type        = string
  description = "Custom domain for API Gateway, e.g. group1-urlshortener.example.com"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for the domain"
}

variable "api_id" {
  type        = string
  description = "API Gateway REST API ID"
}

variable "stage_name" {
  type        = string
  description = "API Gateway stage name (e.g. dev)"
}
