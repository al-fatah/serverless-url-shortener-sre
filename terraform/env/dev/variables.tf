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
