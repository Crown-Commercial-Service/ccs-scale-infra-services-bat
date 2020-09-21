#########################################################
# CloudFront
#
# Distribution for FaT Buyer UI
#########################################################
module "globals" {
  source = "../../globals"
}

resource "random_password" "cloudfront_id" {
  length  = 16
  special = false
  # override_special = "_%@"
}

resource "aws_s3_bucket" "logs" {
  bucket        = "scale-${lower(var.environment)}-s3-${lower(var.name)}-cloudfront-logs"
  acl           = "private"
  force_destroy = var.force_destroy_cloudfront_logs_bucket

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "S3"
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    # domain_name = var.lb_public_dns
    # origin_id   = var.lb_public_dns
    domain_name = var.lb_public_alb_dns
    origin_id   = var.lb_public_alb_dns

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "CloudFrontID"
      value = random_password.cloudfront_id.result
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.description

  web_acl_id = aws_waf_web_acl.buyer_ui.id

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = ${lower(var.name)}
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.lb_public_alb_dns

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "CLOUDFRONT"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}