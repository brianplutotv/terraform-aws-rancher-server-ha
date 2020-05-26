### Route 53

data "aws_route53_zone" "dns_zone" {
  provider = aws.r53
  name     = local.domain
}

resource "aws_route53_record" "rancher" {
  zone_id  = data.aws_route53_zone.dns_zone.zone_id
  name     = local.domain
  type     = "A"
  provider = aws.r53

  alias {
    name                   = aws_elb.rancher.dns_name
    zone_id                = aws_elb.rancher.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "rancher_api" {
  zone_id  = data.aws_route53_zone.dns_zone.zone_id
  name     = "api.${local.domain}"
  ttl      = 60
  type     = "CNAME"
  provider = aws.r53
  records  = [aws_lb.rancher_api.dns_name]
}
