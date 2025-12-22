output "ddb_table_name" {
  value = module.dynamodb.table_name
}

output "create_role_arn" {
  value = module.lambdas.create_role_arn
}

output "retrieve_role_arn" {
  value = module.lambdas.retrieve_role_arn
}
