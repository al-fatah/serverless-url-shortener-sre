output "create_role_arn" {
  value = aws_iam_role.create_role.arn
}

output "retrieve_role_arn" {
  value = aws_iam_role.retrieve_role.arn
}

output "create_lambda_arn" {
  value = aws_lambda_function.create.arn
}

output "retrieve_lambda_arn" {
  value = aws_lambda_function.retrieve.arn
}

output "create_lambda_invoke_arn" {
  value = aws_lambda_function.create.invoke_arn
}

output "retrieve_lambda_invoke_arn" {
  value = aws_lambda_function.retrieve.invoke_arn
}
