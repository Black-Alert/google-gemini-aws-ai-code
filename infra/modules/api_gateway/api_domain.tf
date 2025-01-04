provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
  profile = "BA"
}
resource "aws_api_gateway_domain_name" "this" {
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn
  domain_name     = var.api_domain_name
}

# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "this" {
  name    = aws_api_gateway_domain_name.this.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.this.cloudfront_zone_id
  }
  depends_on = [aws_api_gateway_domain_name.this]
}

resource "aws_acm_certificate" "this" {
  domain_name       = var.api_domain_name
  validation_method = "DNS"
  provider          = aws.us_east
}

resource "aws_route53_record" "this_validate" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
  provider        = aws.us_east
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this_validate : record.fqdn]
  provider                = aws.us_east
}