variable "bucket_prefix" {
  type = string
}

variable "acl" {
  type = string
}

variable "versioning" {
  type = bool
}

# variable "subnet_s3" {
#   type = string
# }

variable "vpc_id_s3" {
  description = "VPC id"
}

variable "csv_user_purchase_path" {
  description = "Path to user purchase CSV file"
}

variable "csv_movie_review_path" {
  description = "Path to movie review CSV file"
}

variable "csv_log_reviews_path" {
  description = "Path to log reviews CSV file"
}

variable "glue_job_path" {
  description = "Path to AWS Glue job path"
}