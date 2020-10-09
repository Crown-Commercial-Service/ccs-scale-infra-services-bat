##################
# Global variables
##################
locals {
  env_accounts = {
    mgmt = "016776319009"
  }
}

variable "environment" {
  type = string
}

output "env_accounts" {
  value = local.env_accounts
}

output "allowed_cors_headers" {
  value = [
    "Authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
    "Access-Control-Request-Headers",
    "Access-Control-Request-Method"
  ]
}

output "project_resource_tags" {
  value = {
    Project     = "SCALE"
    Environment = upper(var.environment)
    Cost_Code   = "PR2-00001"
  }
}
