output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "location" {
  value       = var.location
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = module.gke.kubernetes_cluster_name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = module.gke.kubernetes_cluster_host
  description = "GKE Cluster Host"
}

output "instance_private_address" {
  value = module.cloudsql.instance_private_address
}

output "instance_ip_address" {
  value = module.cloudsql.instance_ip_address
}

output "instance_user_pw" {
  value = module.cloudsql.db_user_password
  sensitive = true
}

output "instance_user_name" {
  value = module.cloudsql.db_user_name
}

output "instance_db_name" {
  value = module.cloudsql.db_name
}

output "instance_name" {
  value = module.cloudsql.instance_name
}

output "dp_cluster_name" {
  value = module.dataproc.dp_cluster_name
}

output "raw_bucket_name" {
  value = var.raw_bucket_name
}

output "staging_bucket_name" {
  value = var.staging_bucket_name
}

output "spark_job_output_name" {
  value = module.buckets.spark_job_output_name
}

output "user_purchase_output_name" {
  value = module.buckets.user_purchase_output_name
}

output "movie_review_output_name" {
  value = module.buckets.movie_review_output_name
}

output "bq_dataset_name" {
  value = var.bq_dataset_id
}

output "sa_key_json_output" {
  value = module.service-account.sa_key_json_output
  sensitive = true
}

