variable "stage" {
  type = string
}

variable "environment" {
  type = string
}

variable "s3_noncurrent_retention_in_days" {
  type = number
}

variable "s3_force_destroy" {
  type = bool
}
