output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "efs" {
  value = module.eks.efs
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_username" {
  value     = module.rds.rds_username
  sensitive = true
}

output "rds_password" {
  value     = module.rds.rds_password
  sensitive = true
}

output "rds_database" {
  value = module.rds.rds_database
}

output "s3_bucket_name" {
  value = module.s3.s3_bucket_id
}

output "s3_csv_movie_review_key" {
  value = module.s3.s3_csv_movie_review_key
}

output "s3_csv_log_reviews_key" {
  value = module.s3.s3_csv_log_reviews_key
}

output "s3_csv_user_purchase_key" {
  value = module.s3.s3_csv_user_purchase_key
}

output "gj_name" {
  value = module.glue.gj_name
}

output "gj_script_location" {
  value = module.glue.gj_script_location
}

output "ath-db-name" {
  value = module.athena.ath-db-name
}

output "ath-out-bucket" {
  value = module.athena.ath-out-bucket
}