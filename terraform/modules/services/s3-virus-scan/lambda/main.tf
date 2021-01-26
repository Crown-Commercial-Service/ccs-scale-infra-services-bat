##########################################################
# Lambda
#
#
##########################################################
module "globals" {
  source      = "../../../globals"
  environment = var.environment
}

data "aws_iam_policy_document" "lambda_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type     = "Service"
      identifiers = ["lambda.amazonaws.com", "s3.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_role" {
  name               = "SCALE_LAMBDA_BAT"
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_role.arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "lambda_ccs_virus_scan_zip" {
  type          = "zip"
  source_dir  = "${path.module}/ccs-virus-scan"
  output_path = "${path.module}/.build/ccs-virus-scan.zip"
}

resource "aws_lambda_function" "ccs_virus_scan_lambda" {
  filename         = "${path.module}/.build/ccs-virus-scan.zip"
  source_code_hash = data.archive_file.lambda_ccs_virus_scan_zip.output_base64sha256
  function_name    = "ccs-${lower(var.environment)}-virus-scan"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  timeout          = 30
  publish          = true

  environment {
    variables = {
      HOST = var.host
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_groups
  }
}

