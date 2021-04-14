##########################################################
# S3
#
# Buckets and initial objects
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

resource "aws_s3_bucket" "static" {
  bucket        = "spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = var.s3_force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-noncurrent-after-${var.s3_noncurrent_retention_in_days}-days"
    enabled = true
    noncurrent_version_expiration {
      days = var.s3_noncurrent_retention_in_days
    }
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket" "cnet" {
  bucket        = "cnet-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = var.s3_force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-noncurrent-after-${var.s3_noncurrent_retention_in_days}-days"
    enabled = true
    noncurrent_version_expiration {
      days = var.s3_noncurrent_retention_in_days
    }
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket" "product-import" {
  bucket        = "spree-${lower(var.environment)}-products-import"
  force_destroy = var.s3_force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-noncurrent-after-${var.s3_noncurrent_retention_in_days}-days"
    enabled = true
    noncurrent_version_expiration {
      days = var.s3_noncurrent_retention_in_days
    }
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}
