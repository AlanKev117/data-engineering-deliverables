resource "google_storage_bucket" "raw-bucket" {
  name     = var.raw_bucket_name
  location = var.location

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}
