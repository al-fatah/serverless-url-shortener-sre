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
