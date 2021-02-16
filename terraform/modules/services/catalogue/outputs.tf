output "catalogue_api_gateway_integration" {
  value = aws_api_gateway_integration.catalogue_proxy.http_method
}

output "ecs_service_name" {
  value = aws_ecs_service.catalogue.name
}
