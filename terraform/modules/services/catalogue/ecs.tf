
#########################################################
# Service: Catalogue Service ECS
#
# ECS Fargate Service and Task Definitions.
#########################################################
module "globals" {
  source      = "../../globals"
  environment = var.environment
}

#######################################################################
# NLB target group & listener for traffic on port 8010 (Catalogue API)
#######################################################################
resource "aws_lb_target_group" "target_group_8010" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-Catalogue"
  port        = 8010
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

resource "aws_lb_listener" "port_8010" {
  load_balancer_arn = var.lb_private_arn
  port              = "8010"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_8010.arn
  }
}

resource "aws_ecs_service" "catalogue" {
  name             = "SCALE-EU2-${upper(var.environment)}-APP-ECS_Service_Catalogue"
  cluster          = var.ecs_cluster_id
  task_definition  = aws_ecs_task_definition.catalogue.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  desired_count    = length(var.private_app_subnet_ids)

  network_configuration {
    security_groups  = [aws_security_group.allow_http.id]
    subnets          = var.private_app_subnet_ids
    assign_public_ip = false # Replace NAT GW and disable this by replacement AWS PrivateLink
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_8010.arn
    container_name   = "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Catalogue"
    container_port   = 8010
  }
}

resource "aws_ecs_task_definition" "catalogue" {
  family                   = "catalogue"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.catalogue_cpu
  memory                   = var.catalogue_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = <<DEFINITION
    [
      {
        "name": "SCALE-EU2-${upper(var.environment)}-APP-ECS_TaskDef_Catalogue",
        "image": "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/catalogue-service:${var.ecr_image_id_catalogue}",
        "requires_compatibilities": "FARGATE",
        "cpu": ${var.catalogue_cpu},
        "memory": ${var.catalogue_memory},
        "essential": true,
        "networkMode": "awsvpc",
        "portMappings": [
            {
            "containerPort": 8010,
            "hostPort": 8010
            }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.fargate_scale.name}",
              "awslogs-region": "eu-west-2",
              "awslogs-stream-prefix": "fargate-catalogue"
          }
        }
      }
    ]
DEFINITION

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_cloudwatch_log_group" "fargate_scale" {
  name_prefix       = "/fargate/service/scale/catalogue"
  retention_in_days = var.ecs_log_retention_in_days
}

#########################################################
# ECS Security Group and Policy
#########################################################
resource "aws_security_group" "allow_http" {
  name                   = "allow_http_ecs_catalogue"
  description            = "Allow HTTP access to ECS Services"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 8010
    to_port     = 8010
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "SCALE_ECS_Shared_Services_Task_Execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_iam_policy" "ecs_task_execution" {
  description = "ECS task execution policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}


/////
output "ecs_security_group_id" {
  value = aws_security_group.allow_http.id
}

output "ecs_task_execution_arn" {
  value = aws_iam_role.ecs_task_execution.arn
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.scale.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.scale.name
}