output "spark_job_output_name" {
  value = google_storage_bucket_object.spark-job.output_name
}

output "user_purchase_output_name" {
  value = google_storage_bucket_object.user-purchase.output_name
}

output "movie_review_output_name" {
  value = google_storage_bucket_object.movie-review.output_name
}