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
      service_account_scopes = [ "cloud-platform" ]
    }

    staging_bucket = google_storage_bucket.staging-bucket.name
    # staging_bucket = var.staging_bucket_name
    temp_bucket = google_storage_bucket.temp-bucket.name
    # temp_bucket = var.temp_bucket_name
  }
}

resource "google_storage_bucket" "staging-bucket" {
  name     = var.staging_bucket_name
  location = var.location

  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

resource "google_storage_bucket" "temp-bucket" {
  name     = var.temp_bucket_name
  location = var.location

  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}