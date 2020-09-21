#########################################################
# Service: API Deployments
#
# Creates Usage Plan/API Keys and deployment.
#########################################################

#########################################################
# Deployment
#########################################################
resource "aws_api_gateway_deployment" "bat" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id

  depends_on = [
    var.client_api_gateway_integration,
    //var.guided_match_api_gateway_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "bat" {
  description = "Deployed at ${timestamp()}"
  depends_on = [
    aws_cloudwatch_log_group.api_gw_execution
  ]

  stage_name    = lower(var.environment)
  rest_api_id   = var.scale_rest_api_id
  deployment_id = aws_api_gateway_deployment.bat.id
}

resource "aws_api_gateway_method_settings" "scale" {
  rest_api_id = var.scale_rest_api_id
  stage_name  = aws_api_gateway_stage.bat.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_cloudwatch_log_group" "api_gw_execution" {
  name              = "API-Gateway-Execution-Logs_${var.scale_rest_api_id}/${lower(var.environment)}-bat"
  retention_in_days = 7
}


#########################################################
# Usage Plans
#########################################################
/*
resource "aws_api_gateway_usage_plan" "default" {
  name        = "default-usage-plan"
  description = "Default Usage Plan"

  api_stages {
    api_id = var.scale_rest_api_id
    stage  = aws_api_gateway_stage.bat.stage_name
  }

  throttle_settings {
    rate_limit  = var.api_rate_limit
    burst_limit = var.api_burst_limit
  }
}
*/
#########################################################
# API Keys
#########################################################
/*
resource "aws_api_gateway_api_key" "fat_buyer_ui" {
  name = "FaT Buyer UI API Key (FaT)"
}

resource "aws_api_gateway_api_key" "fat_testers" {
  name = "FaT Testers API Key (FaT)"
}

resource "aws_api_gateway_api_key" "fat_developers" {
  name = "FaT Developers API Key (FaT)"
}

resource "aws_api_gateway_usage_plan_key" "fat_buyer_ui" {
  key_id        = aws_api_gateway_api_key.fat_buyer_ui.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_testers" {
  key_id        = aws_api_gateway_api_key.fat_testers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_developers" {
  key_id        = aws_api_gateway_api_key.fat_developers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
*/