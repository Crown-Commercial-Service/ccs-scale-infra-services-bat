##########################################################
# ECS
#
# ECS shared resources
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

/*
locals {
  cluster_name = "SCALE-EU2-${var.environment}-APP-ECS_BAT_${var.resource_name_suffix}"
}

resource "aws_ecs_cluster" "main" {
  name = local.cluster_name
}
*/
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "SCALE-EU2-${var.environment}-APP-ECS_BAT_${var.resource_name_suffix}"
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name

  desired_capacity = length(var.subnet_ids)
  min_size         = length(var.subnet_ids)
  max_size         = length(var.subnet_ids)
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name_prefix                 = "SCALE-EU2-${var.environment}-ASG-LC_BAT_${var.resource_name_suffix}_"
  image_id                    = "ami-09f5dea513082ee2d"
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  user_data                   = data.template_file.user_data.rendered
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  key_name                    = "${lower(var.environment)}-spree-key"
  security_groups             = var.security_group_ids

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    cluster_name = local.cluster_name
  }
}

# Define the role.
resource "aws_iam_role" "ecs_agent" {
  name               = "SCALE_ECS_BAT_${var.resource_name_suffix}_Agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

# Allow EC2 service to assume this role.
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Give this role the permission to do ECS Agent things.
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = aws_iam_role.ecs_agent.name
  role = aws_iam_role.ecs_agent.name
}

#########################################################
# ECS Security Group and Policy
#########################################################
resource "aws_security_group" "allow_http" {
  name                   = "allow_http_ecs_shared"
  description            = "Allow HTTP access to ECS Services"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 9010
    to_port     = 9010
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_vpc]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
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
    cidr_blocks     = [var.cidr_block_vpc]
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
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

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "ECS"
  }
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
