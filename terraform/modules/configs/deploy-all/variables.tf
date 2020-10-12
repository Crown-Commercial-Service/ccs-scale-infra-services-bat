variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "stage" {
  type    = string
  default = "staging"
}

variable "api_rate_limit" {
  type    = number
  default = 10000
}

variable "api_burst_limit" {
  type    = number
  default = 5000
}

variable "ecr_image_id_spree" {
  type    = string
  default = "latest"
}

variable "ecr_image_id_client" {
  type    = string
  default = "latest"
}

variable "rollbar_env" {
  type    = string
}
