output "alb_front" {
  value = aws_alb.alb_front.dns_name
  description = "the DNS name of the frontend load balancer"
}

output "alb_back" {
  value = aws_alb.alb_back.dns_name
  description = "the DNS name of the backend load balancer"
}
