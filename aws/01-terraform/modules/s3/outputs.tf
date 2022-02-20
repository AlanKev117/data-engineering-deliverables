output "s3_bucket_id" {
  value = aws_s3_bucket.bucket.id
}
output "s3_bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}
output "s3_bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}
output "s3_hosted_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}
output "s3_bucket_region" {
  value = aws_s3_bucket.bucket.region
}

output "s3_csv_movie_review_key" {
  value = aws_s3_bucket_object.csv_movie_review.id
}

output "s3_csv_log_reviews_key" {
  value = aws_s3_bucket_object.csv_log_reviews.id
}

output "s3_csv_user_purchase_key" {
  value = aws_s3_bucket_object.csv_user_purchase.id
}

output "s3_glue_job_key" {
  value = aws_s3_bucket_object.glue_job.id
}
