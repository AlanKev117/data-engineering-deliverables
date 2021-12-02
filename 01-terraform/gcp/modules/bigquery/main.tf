resource "google_bigquery_dataset" "default" {
  dataset_id                  = var.bq_dataset_id
  friendly_name               = "Warehousing"
  description                 = "Dataset for warehousing"
  location                    = var.bq_location
  default_table_expiration_ms = 3600000
  delete_contents_on_destroy  = true

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bqowner.email
  }

}

resource "google_service_account" "bqowner" {
  account_id = "bqowner"
}
