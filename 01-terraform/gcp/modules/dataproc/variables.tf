variable "location" {
  description = "Value for DP cluster zone"
}

variable "region" {
  description = "Region the cluster will be instanciated in"
}

variable "dp_cluster_name" {
  description = "Name for DP cluster"

}

variable "subnetwork_name" {
  description = "Name of the subnetwork the cluster will live in"
}

variable "staging_bucket_name" {
  description = "Name for the Dataproc cluster's staging bucket"
}

variable "temp_bucket_name" {
  description = "Name for the Dataproc cluster's temp bucket"
}