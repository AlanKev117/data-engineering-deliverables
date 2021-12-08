resource "google_dataproc_cluster" "dp-cluster" {
  name   = var.dp_cluster_name
  region = var.region

  cluster_config {

    master_config {
      num_instances = 1
      machine_type  = var.dp_cluster_machine_type
    }

    worker_config {
      num_instances = var.dp_cluster_workers
      machine_type  = var.dp_cluster_machine_type
    }

    gce_cluster_config {
      zone    = var.location
      subnetwork = var.subnetwork_name
      service_account_scopes = [ "cloud-platform" ]
      metadata = {
        "PIP_PACKAGES" = "textblob"
      }
    }

    software_config {
      image_version = "2.0"
      override_properties = {
        "dataproc:dataproc.pip.packages" = "textblob"
      }
    }

    # staging_bucket = google_storage_bucket.staging-bucket.name
    staging_bucket = var.staging_bucket_name
    # temp_bucket = google_storage_bucket.raw-bucket.name
    temp_bucket = var.raw_bucket_name
  }
}