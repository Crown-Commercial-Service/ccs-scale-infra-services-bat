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
  force_destroy = true

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

# Deprecated (as of SINF-356) - this bucket is no longer needed.
# Leaving for now, as these buckets contain .env files which have info that
# may be needed for a short while after transition to system param approach.
# To be removed as part of follow up task SINF-371
resource "aws_s3_bucket" "system" {
  bucket        = "system-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket" "feed" {
  bucket        = "feed-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket" "cnet" {
  bucket        = "cnet-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket_object" "env-spree" {
  bucket = aws_s3_bucket.system.id
  key    = "spree.env"
  acl    = "private"

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}

resource "aws_s3_bucket" "product-import" {
  bucket        = "spree-${lower(var.environment)}-products-import"
  force_destroy = true

  tags = merge(module.globals.project_resource_tags, { AppType = "S3" })
}
