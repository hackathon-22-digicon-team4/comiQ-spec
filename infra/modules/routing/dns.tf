data "aws_route53_zone" "host_zone" {
  name = "kyosutech.com"
}

#ホストゾーン
resource "aws_route53_zone" "subdomain" {
  name = "comiq.${data.aws_route53_zone.host_zone.name}"

  tags = {
    Name = "${var.project}_${var.stage}_r53_zone"
  }
}

resource "aws_route53_record" "ns_record_for_subdomain" {
  name    = aws_route53_zone.subdomain.name
  zone_id = data.aws_route53_zone.host_zone.arn
  records = [
    aws_route53_zone.subdomain.name_servers[0],
    aws_route53_zone.subdomain.name_servers[1],
    aws_route53_zone.subdomain.name_servers[2],
    aws_route53_zone.subdomain.name_servers[3]
  ]
  ttl  = 300
  type = "NS"
}

resource "aws_route53_record" "api_dns_record" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "api.${aws_route53_zone.subdomain.name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
