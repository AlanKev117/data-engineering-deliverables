module "vpc" {
  source = "./modules/vpc"

  project_id = var.project_id

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

  dp_cluster_name = var.dp_cluster_name
  region          = var.region
  location        = var.location
  subnetwork_name = module.vpc.private_subnetwork_name
}


module "raw-bucket" {
  source = "./modules/raw-bucket"
  
  raw_bucket_name = var.raw_bucket_name
  location = var.region
}

module "staging-bucket" {
  source = "./modules/staging-bucket"
  
  staging_bucket_name = var.staging_bucket_name
  location = var.region
}