##########################################################
# Infrastructure: ECS
#
# Creates Single cluster and shared resources for all BaT
# Fargate ECS deployments
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

locals {
  cluster_name = "SCALE-EU2-${var.environment}-APP-ECS_BAT"
}

resource "aws_ecs_cluster" "scale" {
  name = local.cluster_name

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

data "aws_vpc_endpoint" "ecr" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.ecr.dkr"
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.eu-west-2.s3"
}

#########################################################
# ECS Security Group and Policy
#########################################################
resource "aws_security_group" "allow_http" {
  name                   = "allow_http_ecs_fargate_bat"
  description            = "Allow HTTP access to ECS BAT Fargate Services"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    # Catalogue API Service
    from_port   = 9030
    to_port     = 9030
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }
  
  ingress {
    # Auth API Service
    from_port   = 9040
    to_port     = 9040
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  # Allow traffic to/from ECR and S3 endpoints via VPC link
  # https://7thzero.com/blog/limiting-outbound-egress-traffic-while-using-aws-fargate-and-ecr
  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = data.aws_vpc_endpoint.ecr.security_group_ids # SG ID of VPC ECR endpoint
    prefix_list_ids = [data.aws_vpc_endpoint.s3.prefix_list_id]    # Prefix list ID of S3 endpoint

    # TODO: SINF-67 - DO NOT REMOVE '0.0.0.0/0' yet
    # (Fixed IP range for connection to CCS Web CMS not yet available)
    cidr_blocks = [var.cidr_block_vpc, "0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "ECS" })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "SCALE_ECS_BAT_Services_Fargate_Task_Execution"

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
  description = "BaT ECS Fargate task execution policy"

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
