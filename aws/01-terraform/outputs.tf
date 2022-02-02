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

output "s3_bucket_name" {
  value = module.s3.s3_bucket_id
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_username" {
  value = module.rds.rds_username
  sensitive = true
}

output "rds_password" {
  value = module.rds.rds_password
  sensitive = true
}

output "rds_database" {
  value = module.rds.rds_database
}