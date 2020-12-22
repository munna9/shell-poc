locals{
  stripped_domain_name = replace(var.domain_name, "/[.]$/", "")
}

data "aws_route53_zone" "ses_domain" {
  count = var.enable_verification ? 1 : 0
  name = var.domain_name
}

resource "aws_ses_domain_identity" "main" {
  domain = local.stripped_domain_name
}

resource "aws_ses_domain_identity_verification" "main" {
  count = var.enable_verification ? 1 : 0
  domain = aws_ses_domain_identity.main.id
  depends_on = [aws_route53_record.ses_verification]
}

resource "aws_route53_record" "ses_verification" {
  count = var.enable_verification ? 1 : 0
  zone_id = data.aws_route53_zone.ses_domain[count.index].id
  name    = "_amazonses.${aws_ses_domain_identity.main.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_ses_email_identity" "email_identity" {
  count = length(var.from_addresses)
  email = var.from_addresses[count.index]
}
