
#########################################################
# Service: Auth Service ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source      = "../../globals"
  environment = var.environment
}

#######################################################################
# NLB target group & listener for traffic on port 9040 (Auth API)
#######################################################################
resource "aws_lb_target_group" "target_group_9040" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-auth"
  port        = 9040
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

resource "aws_lb_listener" "port_9040" {
  load_balancer_arn = var.lb_private_arn
  port              = "9040"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_9040.arn
  }
}

resource "aws_ecs_service" "auth" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_Auth"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.auth.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = length(var.private_app_subnet_ids)

  network_configuration {
    security_groups  = [var.ecs_security_group_id]
    subnets          = var.private_app_subnet_ids
    assign_public_ip = false # Replace NAT GW and disable this by replacement AWS PrivateLink
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_9040.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Auth"
    container_port   = 9040
  }
}

resource "aws_ecs_task_definition" "auth" {
  family                   = "auth"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.auth_cpu
  memory                   = var.auth_memory
  execution_role_arn       = var.ecs_task_execution_arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Auth",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/auth-service:${var.ecr_image_id_auth}",
        "requires_compatibilities": "FARGATE",
        "cpu": ${var.auth_cpu},
        "memory": ${var.auth_memory},
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 9040,
            "hostPort": 9040
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-auth"
          }
        },
        "environment": [
            {
                "name": "SPREE_API_HOST",
                "value": "${var.spree_api_host}"
            }
        ]
      }
    ]
DEFINITION

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_cloudwatch_log_group" "fargate_scale" {
  name_prefix       = "/fargate/service/scale/auth"
  retention_in_days = var.ecs_log_retention_in_days
}
