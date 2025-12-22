terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "dynamodb" {
  source        = "../../modules/dynamodb"
  table_name    = var.ddb_table_name
  ttl_attribute = "ttl"
}

module "lambdas" {
  source         = "../../modules/lambdas"
  project_name   = var.project_name
  region         = var.region
  ddb_table_name = module.dynamodb.table_name
  ddb_table_arn  = module.dynamodb.table_arn

  create_zip_path   = "${path.module}/artifacts/create-url-lambda.zip"
  retrieve_zip_path = "${path.module}/artifacts/retrieve-url-lambda.zip"
  app_url           = var.app_url
}
