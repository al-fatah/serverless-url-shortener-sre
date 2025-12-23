data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Allow APIGW to invoke Create Lambda
resource "aws_lambda_permission" "allow_apigw_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = var.create_lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/POST/newurl"
}

# Allow APIGW to invoke Retrieve Lambda
resource "aws_lambda_permission" "allow_apigw_retrieve" {
  statement_id  = "AllowAPIGatewayInvokeRetrieve"
  action        = "lambda:InvokeFunction"
  function_name = var.retrieve_lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/GET/*"
}
