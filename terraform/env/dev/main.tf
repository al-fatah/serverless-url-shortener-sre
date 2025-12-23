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

# -----------------------
# Core infrastructure
# -----------------------
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

  # Use custom domain if provided, otherwise fallback to app_url var
  app_url = var.custom_domain_name != "" ? "https://${var.custom_domain_name}" : var.app_url
}

module "apigw" {
  source = "../../modules/apigw"

  project_name = var.project_name

  create_lambda_arn          = module.lambdas.create_lambda_arn
  retrieve_lambda_arn        = module.lambdas.retrieve_lambda_arn
  create_lambda_invoke_arn   = module.lambdas.create_lambda_invoke_arn
  retrieve_lambda_invoke_arn = module.lambdas.retrieve_lambda_invoke_arn
}

# -----------------------
# Custom domain (optional)
# -----------------------
module "custom_domain" {
  count = var.custom_domain_name != "" ? 1 : 0

  source = "../../modules/custom_domain"

  domain_name    = var.custom_domain_name
  hosted_zone_id = var.hosted_zone_id

  api_id     = module.apigw.rest_api_id
  stage_name = module.apigw.stage_name
}

# -----------------------
# WAF (optional but recommended)
# -----------------------
locals {
  apigw_stage_arn = "arn:aws:apigateway:${var.region}::/restapis/${module.apigw.rest_api_id}/stages/${module.apigw.stage_name}"
}

module "waf" {
  # If you want to allow turning WAF off, we can add count like custom_domain.
  source = "../../modules/waf"

  project_name    = var.project_name
  allowed_ips     = var.allowed_ips
  apigw_stage_arn = local.apigw_stage_arn
}
