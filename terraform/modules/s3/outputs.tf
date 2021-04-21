output "s3_static_bucket_name" {
  value = aws_s3_bucket.static.id
}

output "s3_product_import_name" {
  value = aws_s3_bucket.product-import.id
}

output "s3_cnet_import_bucket_name" {
  value = aws_s3_bucket.cnet.id
}
