output "ddb_table_name" {
  value = module.dynamodb.table_name
}

output "create_role_arn" {
  value = module.lambdas.create_role_arn
}

output "retrieve_role_arn" {
  value = module.lambdas.retrieve_role_arn
}

output "create_lambda_arn" {
  value = module.lambdas.create_lambda_arn
}

output "retrieve_lambda_arn" {
  value = module.lambdas.retrieve_lambda_arn
}

output "api_invoke_url" {
  value = module.apigw.invoke_url
}

output "custom_domain_base_url" {
  value = var.custom_domain_name != "" ? module.custom_domain[0].custom_invoke_base_url : ""
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}

output "waf_log_group_name" {
  value = module.waf.waf_log_group_name
}