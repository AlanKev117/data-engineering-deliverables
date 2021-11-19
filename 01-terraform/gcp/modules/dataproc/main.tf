resource "google_dataproc_cluster" "dp-cluster" {
  name   = var.dp_cluster_name
  region = var.region

  cluster_config {

    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-2"
    }

    gce_cluster_config {
      zone    = var.location
      subnetwork = var.subnetwork_name
    }
  }
}
