#########################################################
# Service: Guided Match API
#
# Deploy API Gateway resources for service.
#########################################################
resource "aws_api_gateway_resource" "client" {
  rest_api_id = var.scale_rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "spree-client"
}

resource "aws_api_gateway_resource" "client_proxy" {
  rest_api_id = var.scale_rest_api_id
  parent_id   = aws_api_gateway_resource.client.id

  # Proxy all requests to /guided-match-service/* through to backend
  path_part = "{proxy+}"
}

module "client_cors" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.1"
  api_id          = var.scale_rest_api_id
  api_resource_id = aws_api_gateway_resource.client_proxy.id
  allow_headers   = module.globals.allowed_cors_headers
}

resource "aws_api_gateway_method" "client_proxy" {
  rest_api_id   = var.scale_rest_api_id
  resource_id   = aws_api_gateway_resource.client_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  //api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "client_proxy" {
  rest_api_id             = var.scale_rest_api_id
  resource_id             = aws_api_gateway_resource.client_proxy.id
  http_method             = aws_api_gateway_method.client_proxy.http_method
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.lb_private_dns}:7010/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  integration_http_method = "ANY"
  cache_key_parameters    = ["method.request.path.proxy"]
  cache_namespace         = "client"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
