##########################################################
# S3
#
# Buckets and initial objects
##########################################################
resource "aws_s3_bucket" "static" {
  bucket        = "spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true
}

resource "aws_s3_bucket" "system" {
  bucket        = "system-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true
}

resource "aws_s3_bucket" "feed" {
  bucket        = "feed-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true
}

resource "aws_s3_bucket" "cnet" {
  bucket        = "cnet-spree-${lower(var.environment)}-${lower(var.stage)}"
  force_destroy = true
}

resource "aws_s3_bucket_object" "env-spree" {
  bucket  = aws_s3_bucket.system.id
  key     = "spree.env"
  acl     = "private"
}

resource "aws_s3_bucket_object" "env-client" {
  bucket  = aws_s3_bucket.system.id
  key     = "client.env"
  acl     = "private"
}
