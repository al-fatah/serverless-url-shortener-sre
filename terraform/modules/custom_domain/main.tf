# 1) ACM cert (in same region as your API Gateway REGIONAL endpoint)
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 2) Route53 DNS validation record (single-domain cert)
resource "aws_route53_record" "cert_validation" {
  count = 1

  zone_id = var.hosted_zone_id

  name    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  ttl     = 60
  records = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]

  allow_overwrite = true
}

# 3) Validate the cert
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
}


# 4) API Gateway custom domain (REGIONAL)
resource "aws_api_gateway_domain_name" "this" {
  domain_name = var.domain_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  regional_certificate_arn = aws_acm_certificate_validation.this.certificate_arn
}

# 5) Base path mapping: map your custom domain root to /dev stage
resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.api_id
  stage_name  = var.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name

  depends_on = [aws_api_gateway_domain_name.this]
}

# 6) Route53 alias record -> API Gateway regional domain
resource "aws_route53_record" "apigw_alias" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
    evaluate_target_health = false
  }
}
