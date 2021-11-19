resource "google_storage_bucket" "staging-bucket" {
  name     = var.staging_bucket_name
  location = var.location

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}
