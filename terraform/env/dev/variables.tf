variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "urlshortener-dev"
}

variable "ddb_table_name" {
  type    = string
  default = "urlshortener-dev-links"
}

variable "app_url" {
  type        = string
  description = "Base URL where short links will resolve (set later to your custom domain)"
  default     = "https://example.com"
}

variable "custom_domain_name" {
  type        = string
  description = "Custom domain for API Gateway, e.g. group1-urlshortener.sctp-sandbox.com"
  default     = ""
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID where the custom domain will be created"
  default     = ""
}

variable "allowed_ips" {
  type        = list(string)
  description = "Allowed IP CIDRs for WAF allowlist"
  default     = []
}