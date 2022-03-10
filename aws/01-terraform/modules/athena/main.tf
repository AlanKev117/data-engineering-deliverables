resource "aws_s3_bucket" "ath-dea-results" {
  bucket = "ath-dea-results"
  force_destroy = true
}

resource "aws_athena_database" "deanalytics" {
  name   = "deanalytics"
  bucket = aws_s3_bucket.ath-dea-results.bucket
  force_destroy = true
}