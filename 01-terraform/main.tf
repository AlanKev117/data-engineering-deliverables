module "vpc" {
  source = "./modules/vpc"
  
  project_id = var.project_id
  region = var.region
}

module "gke" {
  source = "./modules/gke"

  project_id    = var.project_id
  cluster_name  = "airflow-gke-data-bootcamp"
  location      = var.location
  vpc_id        = module.vpc.vpc
  subnet_id     = module.vpc.private_subnets[0]
  gke_num_nodes = var.gke_num_nodes
  machine_type  = var.machine_type

}

module "cloudsql" {
  source = "./modules/cloudsql"

  project_id         = var.project_id
  region             = var.region
  location           = var.location
  instance_name      = var.instance_name
  database_version   = var.database_version
  instance_tier      = var.instance_tier
  disk_space         = var.disk_space
  database_name      = var.database_name
  db_username        = var.db_username
  private_network_id = module.vpc.private_network_id
  address_name       = module.vpc.address_name
}


module "dataproc" {
  source = "./modules/dataproc"

  dp_cluster_name = "pyspark-cluster-de-af"
  dp_cluster_workers = var.dp_cluster_workers
  dp_cluster_machine_type = var.dp_cluster_machine_type

  region          = var.region
  location        = var.location
  subnetwork_name = module.vpc.private_subnetwork_name
  staging_bucket_name = var.staging_bucket_name
  raw_bucket_name = var.raw_bucket_name
}

module "bigquery" {
  source = "./modules/bigquery"
  bq_dataset_id = var.bq_dataset_id
  bq_location = var.region
}

module "buckets" {
  source = "./modules/buckets"

  raw_bucket_name = var.raw_bucket_name
  staging_bucket_name = var.staging_bucket_name
  location = var.region
  
  spark_job_path = var.spark_job_path
  user_purchase_path = var.user_purchase_path
  movie_review_path = var.movie_review_path
}

module "service-account" {
  source = "./modules/service-account"

  project_id = var.project_id
}