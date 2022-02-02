variable "raw_bucket_name" {
  description = "Name for the raw bucket"
}

variable "staging_bucket_name" {
  description = "Name for the staging bucket"
}

variable "location" {
  description = "Region for the raw_bucket"
}

variable "spark_job_path" {
  description = "Local path to the Spark job to store in a bucket"
}

variable "movie_review_path" {
  description = "Local path to csv file that contains movie reviews"
}

variable "user_purchase_path" {
  description = "Local path to csv file that contains user purchases"
}