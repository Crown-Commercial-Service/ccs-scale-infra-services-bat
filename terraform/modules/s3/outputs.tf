output "env_file_spree" {
  value = "${aws_s3_bucket.system.arn}/${aws_s3_bucket_object.env-spree.id}"
}

output "s3_static_bucket_name" {
  value = aws_s3_bucket.static.id
}

output "s3_product_import_name" {
  value = aws_s3_bucket.product-import.id
}

output "s3_cnet_import_bucket_name" {
  value = aws_s3_bucket.cnet.id
}

output "s3_static_bucket_arn" {
  value = aws_s3_bucket.static.arn
}

output "s3_product_import_bucket_arn" {
  value = aws_s3_bucket.product-import.arn
}

output "s3_cnet_bucket_arn" {
  value = aws_s3_bucket.cnet.arn
}

output "s3_feed_bucket_arn" {
  value = aws_s3_bucket.feed.arn
}
