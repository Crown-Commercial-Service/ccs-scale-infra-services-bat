##############################################################
#
# Temporary Load Balancers for BaT
#
#
##############################################################

module "globals" {
  source      = "../globals"
  environment = var.environment
}

resource "aws_lb" "public_alb" {
  name               = "SCALE-EU2-${upper(var.environment)}-ALB-EXT-${upper(var.lb_suffix)}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_web_subnet_ids
  security_groups    = [aws_security_group.public_alb_cf_global.id, aws_security_group.public_alb_cf_regional.id]
  #depends_on         = [aws_internet_gateway.scale]

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

resource "aws_security_group" "public_alb_cf_global" {
  name                   = "allow_alb_external_cloudfront_only_${lower(var.lb_suffix)}"
  description            = "Allow ingress from Cloudfront only via update sg lambda"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  # TODO: Use the auto update lambda to manage these ingress rules
  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_security_group" "public_alb_cf_regional" {
  name                   = "allow_alb_external_cloudfront_only_regional_${lower(var.lb_suffix)}"
  description            = "Allow ingress from Cloudfront only via update sg lambda"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }
  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })

}
