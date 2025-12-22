variable "project_name" { type = string }
variable "region" { type = string }

variable "ddb_table_name" { type = string }
variable "ddb_table_arn" { type = string }

# For Lambda code deployment (filled in next commit)
variable "create_zip_path" {
  type        = string
  description = "Path to create lambda zip"
  default     = ""
}

variable "retrieve_zip_path" {
  type        = string
  description = "Path to retrieve lambda zip"
  default     = ""
}

variable "app_url" {
  type        = string
  description = "Base URL for short links, e.g. https://domain/"
  default     = ""
}
