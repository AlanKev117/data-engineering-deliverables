variable "location" {
  description = "Value for DP cluster zone"
}

variable "region" {
  description = "Region the cluster will be instanciated in"
}

variable "dp_cluster_name" {
  description = "Name for DP cluster"
}

variable "dp_cluster_workers" {
  description = "Amount of workers in the Dataproc cluster"
}

variable "dp_cluster_machine_type" {
  description = "Machine type that will run each Dataproc worker"
}

variable "subnetwork_name" {
  description = "Name of the subnetwork the cluster will live in"
}

variable "staging_bucket_name" {
  description = "Name for the Dataproc cluster's staging bucket"
}

variable "raw_bucket_name" {
  description = "Name for the Dataproc cluster's temp bucket"
}