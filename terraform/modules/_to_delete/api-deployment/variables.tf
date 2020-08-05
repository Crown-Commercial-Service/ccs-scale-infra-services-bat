variable "environment" {
  type = string
}

variable "scale_rest_api_id" {
  type = string
}

variable "client_api_gateway_integration" {
  type = string
}

variable "api_rate_limit" {
  type = number
}

variable "api_burst_limit" {
  type = number
}
