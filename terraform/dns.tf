data "aws_route53_zone" "fewlines_net" {
  name  = "fewlines.net."
}

resource "aws_route53_zone" "cluster_zone" {
  name = "experimental.k8s.fewlines.net"
}

resource "aws_route53_record" "cluster_zone_ns" {
  zone_id = data.aws_route53_zone.fewlines_net.zone_id
  name    = aws_route53_zone.cluster_zone.name
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.cluster_zone.name_servers
}
