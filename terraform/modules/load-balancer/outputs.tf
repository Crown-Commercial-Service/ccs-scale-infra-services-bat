output "lb_public_alb_arn" {
  value = aws_lb.public_alb.arn
}

output "lb_public_alb_dns" {
  value = aws_lb.public_alb.dns_name
}
