# SSL証明書の作成
resource "aws_acm_certificate" "make_ssl" {
  domain_name               = aws_route53_zone.subdomain.name
  subject_alternative_names = []
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}_${var.stage}_ssl"
  }
}
# SSl証明書の検証
resource "aws_route53_record" "ssl_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.make_ssl.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = aws_route53_zone.subdomain.zone_id
  ttl             = 60
}

# 検証の待機
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.make_ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.ssl_certificate : record.fqdn]
}