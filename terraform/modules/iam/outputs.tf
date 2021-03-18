output "aws_access_key_id_ssm_arn" {
  value = aws_ssm_parameter.aws_access_key_id.arn
}

output "aws_secret_access_key_ssm_arn" {
  value = aws_ssm_parameter.aws_secret_access_key.arn
}
