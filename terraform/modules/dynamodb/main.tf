resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_id"

  attribute {
    name = "short_id"
    type = "S"
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Project = "serverless-url-shortener-sre"
  }
}
