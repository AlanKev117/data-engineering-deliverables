# General GCP vars.
variable "project_id" {
  description = "project id"
}
variable "location" {
  description = "location"
}

variable "region" {
  description = "region"
}


# GKE Airflow cluster vars.
variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

# CloudSQL vars
variable "instance_name" {
  description = "Name for the sql instance database"
  default     = "data-bootcamp"
}

variable "database_version" {
  description = "The MySQL, PostgreSQL or SQL Server (beta) version to use. "
  default     = "POSTGRES_12"
}

variable "instance_tier" {
  description = "Sql instance tier"
  default     = "db-f1-micro"
}

variable "disk_space" {
  description = "Size of the disk in the sql instance"
  default     = 10
}

variable "database_name" {
  description = "Name for the database to be created"
  default     = "dbname"
}

variable "db_username" {
  description = "Username credentials for root user"
  default     = "dbuser"
}

# Cloud Dataproc vars
variable "dp_cluster_workers" {
  description = "Amount of workers in the Dataproc cluster"
}

variable "dp_cluster_machine_type" {
  description = "Machine type that will run each Dataproc worker"
}

# Buckets and initial content vars
variable "raw_bucket_name" {
  description = "Name for the raw_bucket"
}

variable "staging_bucket_name" {
  description = "Name for the Dataproc cluster's staging bucket"
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

# Big Query vars.
variable "bq_dataset_id" {
  description = "BigQuery dataset ID"
}

