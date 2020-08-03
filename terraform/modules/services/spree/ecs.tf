
module "globals" {
  source = "../../globals"
}

#######################################################################
# NLB target group & listener for traffic on port 4567
#######################################################################
resource "aws_lb_target_group" "target_group_4567" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-BaTSpree"
  port        = 4567
  #protocol    = "TCP"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  # Required for ALB operating over HTTP
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
    path                = "/healthcheck"
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
}

/*
resource "aws_lb_listener" "port_8081" {
  #load_balancer_arn = var.lb_public_arn
  load_balancer_arn = var.lb_public_alb_arn
  port              = "8081"
  #protocol          = "TCP"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<html><body>Unauthorised</body></html>"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "authenticate_cloudfront" {
  listener_arn = aws_lb_listener.port_8081.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567.arn
  }

  condition {
    http_header {
      http_header_name = "CloudFrontID"
      values           = [var.cloudfront_id]
    }
  }
}
*/

resource "aws_lb_listener_rule" "authenticate_and_forwrd" {
  listener_arn = var.lb_public_alb_listner_arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567.arn
  }

  condition {
    http_header {
      http_header_name = "CloudFrontID"
      values           = [var.cloudfront_id]
    }
  }

  condition {
    path_pattern {
      #values = ["/marketplace-platform/admin/*"]
      values = ["/admin/*"]
    }
  }
}

resource "aws_lb_listener_rule" "authenticate_and_forwrd_assets" {
  listener_arn = var.lb_public_alb_listner_arn
  priority     = 4

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567.arn
  }

  condition {
    http_header {
      http_header_name = "CloudFrontID"
      values           = [var.cloudfront_id]
    }
  }

  condition {
    path_pattern {
      #values = ["/marketplace-platform/admin/*"]
      values = ["/assets/spree/*"]
    }
  }
}

# https://github.com/hashicorp/terraform/issues/19601
data "template_file" "app_client" {
  template = file("${path.module}/spree.json.tpl")

  vars = {
    //app_image             = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:hello-world-test-4567"
    app_image                  = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:latest"
    app_port                   = var.app_port
    fargate_cpu                = var.cpu
    fargate_memory             = var.memory
    aws_region                 = var.aws_region
    name                       = "spree-app-task"
    db_name                    = var.db_name
    db_host                    = var.db_host
    db_username                = var.db_username
    db_password                = var.db_password
    secret_key_base            = var.secret_key_base
    basicauth_username         = var.basicauth_username
    basicauth_password         = var.basicauth_password
    rollbar_spree_access_token = var.rollbar_access_token
    env_file                   = var.env_file
    redis_url                  = var.redis_url
    #elasticsearch_url          = var.elasticsearch_url
    memcached_endpoint         = var.memcached_endpoint
    #sidekiq_username           = var.sidekiq_username
    #sidekiq_password           = var.sidekiq_password
    #buyer_ui_url               = var.buyer_ui_url
    #sendgrid_username          = var.sendgrid_username
    #sendgrid_password          = var.sendgrid_password
    #app_domain                 = var.app_domain
    #aws_access_key             = var.aws_access_key
    #aws_secret_access_key      = var.aws_secret_access_key
    #s3_region                  = var.s3_region
    #s3_bucket_name             = var.s3_bucket_name
  }
}

resource "aws_ecs_task_definition" "app_spree" {
  family                   = "spree-app-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.app_client.rendered
}


resource "aws_ecs_service" "spree" {
  name            = "spree-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_spree.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_4567.arn
    container_name   = "spree-app-task"
    container_port   = var.app_port
  }

  //depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_cloudwatch_log_group" "ecs" {
  name      = "/ecs/service/scale/spree"
  retention_in_days = 7
}
