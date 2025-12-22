variable "table_name" {
  type        = string
  description = "DynamoDB table name for short links"
}

variable "ttl_attribute" {
  type        = string
  description = "TTL attribute name"
  default     = "ttl"
}
