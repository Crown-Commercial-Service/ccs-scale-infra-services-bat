##########################################################
# S3
#
# Buckets and initial objects
##########################################################
module "globals" {
  source = "../globals"
}

resource "aws_s3_bucket" "static" {
  bucket        = "spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket" "system" {
  bucket        = "system-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket" "feed" {
  bucket        = "feed-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket" "cnet" {
  bucket        = "cnet-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket_object" "env-spree" {
  bucket  = aws_s3_bucket.system.id
  key     = "spree.env"
  acl     = "private"

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket_object" "env-client" {
  bucket  = aws_s3_bucket.system.id
  key     = "client.env"
  acl     = "private"

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_s3_bucket" "product-import" {
  bucket        = "spree-${lower(var.environment)}-products-import"
  force_destroy = true

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}
