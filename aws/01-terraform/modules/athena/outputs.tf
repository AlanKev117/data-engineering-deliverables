output "ath-db-name" {
  value = aws_athena_database.deanalytics.id
}

output "ath-out-bucket" {
  value = aws_s3_bucket.ath-dea-results.id
}
