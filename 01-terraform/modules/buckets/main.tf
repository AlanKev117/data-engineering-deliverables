resource "google_storage_bucket" "staging-bucket" {
  name     = var.staging_bucket_name
  location = var.location

  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

resource "google_storage_bucket" "raw-bucket" {
  name     = var.raw_bucket_name
  location = var.location

  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

resource "google_storage_bucket_object" "spark-job" {
  name = "pyspark-job.py"
  source = var.spark_job_path
  bucket = google_storage_bucket.raw-bucket.id
}

resource "google_storage_bucket_object" "movie-review" {
  name = "movie_review.csv"
  source = var.movie_review_path
  bucket = google_storage_bucket.raw-bucket.id
}

resource "google_storage_bucket_object" "user-purchase" {
  name = "user_purchase.csv"
  source = var.user_purchase_path
  bucket = google_storage_bucket.raw-bucket.id
}