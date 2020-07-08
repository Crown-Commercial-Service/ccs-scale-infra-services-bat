output "env_file_client" {
  value = "${aws_s3_bucket.system.arn}/${aws_s3_bucket_object.env-client.id}"
}

output "env_file_spree" {
  value = "${aws_s3_bucket.system.arn}/${aws_s3_bucket_object.env-spree.id}"
}

output "s3_static_bucket_name" {
  value = aws_s3_bucket.static.id
}