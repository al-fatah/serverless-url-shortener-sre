resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# -----------------------------
# Resource: /newurl  (POST)
# -----------------------------
resource "aws_api_gateway_resource" "newurl" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "newurl"
}

resource "aws_api_gateway_method" "post_newurl" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.newurl.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda proxy integration for POST
resource "aws_api_gateway_integration" "post_newurl" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.newurl.id
  http_method = aws_api_gateway_method.post_newurl.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.create_lambda_invoke_arn
}

# -----------------------------
# Resource: /{shortid}  (GET)
# -----------------------------
resource "aws_api_gateway_resource" "shortid" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{shortid}"
}

resource "aws_api_gateway_method" "get_shortid" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.shortid.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.shortid" = true
  }
}

# Non-proxy integration so we can map path param -> {"short_id": "..."}
resource "aws_api_gateway_integration" "get_shortid" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.get_shortid.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.retrieve_lambda_invoke_arn

  request_templates = {
    "application/json" = <<EOF
{
  "short_id": "$input.params('shortid')"
}
EOF
  }
}

# Method response: allow 302 and declare Location header is returned
resource "aws_api_gateway_method_response" "get_302" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.get_shortid.http_method
  status_code = "302"

  response_parameters = {
    "method.response.header.Location" = true
  }
}

# Integration response: map Lambda output to Location header
# Your retrieve lambda returns headers.Location = long_url (we already coded this).
resource "aws_api_gateway_integration_response" "get_302" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.get_shortid.http_method
  status_code = aws_api_gateway_method_response.get_302.status_code

  response_parameters = {
    "method.response.header.Location" = "integration.response.body.headers.Location"
  }

  # Use body as-is; client will follow redirect via Location header
  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.get_shortid]
}

# -----------------------------
# Deploy + Stage
# -----------------------------
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Force redeploy when methods/integrations change
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_method.post_newurl.id,
      aws_api_gateway_integration.post_newurl.id,
      aws_api_gateway_method.get_shortid.id,
      aws_api_gateway_integration.get_shortid.id,
      aws_api_gateway_method_response.get_302.id,
      aws_api_gateway_integration_response.get_302.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.post_newurl,
    aws_api_gateway_integration.get_shortid,
    aws_api_gateway_integration_response.get_302
  ]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "dev"

  xray_tracing_enabled = true
}
