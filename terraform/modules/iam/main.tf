##########################################################
# IAM
#
# Spree application user
##########################################################
resource "aws_iam_user" "spree" {
  name          = "spree-app-user"
  force_destroy = true # ensures any non TF access keys are removed automatically
}

resource "aws_iam_access_key" "spree" {
  user = aws_iam_user.spree.name
}

data "aws_ssm_parameter" "kms_id_ssm" {
  name = "${lower(var.environment)}-ssm-encryption-key"
}

# Create System Parameters as we need these to inject as secrets into ECS
resource "aws_ssm_parameter" "aws_access_key_id" {
  name      = "/bat/${lower(var.environment)}-aws-access-key-id"
  type      = "SecureString"
  value     = aws_iam_access_key.spree.id
  overwrite = true
  key_id    = data.aws_ssm_parameter.kms_id_ssm.value
}

resource "aws_ssm_parameter" "aws_secret_access_key" {
  name      = "/bat/${lower(var.environment)}-aws-secret-access-key"
  type      = "SecureString"
  value     = aws_iam_access_key.spree.secret
  overwrite = true
  key_id    = data.aws_ssm_parameter.kms_id_ssm.value
}

resource "aws_iam_user_policy" "spree" {
  name = "spree-user-policy"
  user = aws_iam_user.spree.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = formatlist("%s/*", var.spree_bucket_access_arns)
      },
      {
        Action : ["s3:ListBucket"],
        Effect : "Allow",
        Resource : var.spree_bucket_access_arns
      }
    ]
  })
}
