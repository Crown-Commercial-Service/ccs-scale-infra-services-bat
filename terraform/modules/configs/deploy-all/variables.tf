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
  type = string
}

variable "client_cpu" {
  type    = number
  default = 2048
}

variable "client_memory" {
  type    = number
  default = 4096
}

variable "spree_cpu" {
  type    = number
  default = 4096
}

variable "spree_memory" {
  type    = number
  default = 8192
}

variable "sidekiq_cpu" {
  type    = number
  default = 4096
}

variable "sidekiq_memory" {
  type    = number
  default = 8192
}

variable "client_ec2_instance_type" {
  type    = string
  default = "t2.large"
}

# TODO: Confirm with Som - there is no t2 instance matching 4/8 split on spreadsheet
variable "spree_ec2_instance_type" {
  type    = string
  default = "t2.large"
}

# TODO: Confirm with Som - there is no t2 instance matching 4/8 split on spreadsheet
variable "sidekiq_ec2_instance_type" {
  type    = string
  default = "t2.large"
}
