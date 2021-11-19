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