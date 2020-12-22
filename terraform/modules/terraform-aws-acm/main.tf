resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = var.tags
}

data "aws_route53_zone" "main" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "main" {
  count           = length(var.subject_alternative_names) + 1
  name            = lookup(element(aws_acm_certificate.main.domain_validation_options, count.index), "resource_record_name")
  type            = lookup(element(aws_acm_certificate.main.domain_validation_options, count.index), "resource_record_type")
  zone_id         = data.aws_route53_zone.main.id
  records         = [ lookup(element(aws_acm_certificate.main.domain_validation_options, count.index), "resource_record_value") ]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = aws_route53_record.main.*.fqdn
}
