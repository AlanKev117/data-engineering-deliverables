resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_prefix

  force_destroy = true
  
  versioning {
    enabled = var.versioning
  }

  tags = {
    Name = "s3-data-bootcamp"
  }
}

resource "aws_s3_bucket_object" "csv_user_purchase" {
  bucket = aws_s3_bucket.bucket.id
  key    = "csv/user_purchase.csv"
  source = var.csv_user_purchase_path
}

resource "aws_s3_bucket_object" "csv_movie_review" {
  bucket = aws_s3_bucket.bucket.id
  key    = "csv/movie_review.csv"
  source = var.csv_movie_review_path
}

resource "aws_s3_bucket_object" "csv_log_reviews" {
  bucket = aws_s3_bucket.bucket.id
  key    = "csv/log_reviews.csv"
  source = var.csv_log_reviews_path
}

resource "aws_s3_bucket_object" "glue_job" {
  bucket = aws_s3_bucket.bucket.id
  key    = "aws-glue-jobs/Transform.scala"
  source = var.glue_job_path
}
