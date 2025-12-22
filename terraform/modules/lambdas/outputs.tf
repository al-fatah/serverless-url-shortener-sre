output "create_role_arn" {
  value = aws_iam_role.create_role.arn
}

output "retrieve_role_arn" {
  value = aws_iam_role.retrieve_role.arn
}
