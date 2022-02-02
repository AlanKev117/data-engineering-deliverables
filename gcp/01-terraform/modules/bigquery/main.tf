resource "google_bigquery_dataset" "default" {
  dataset_id                  = var.bq_dataset_id
  friendly_name               = "Warehousing"
  description                 = "Dataset for warehousing"
  location                    = var.bq_location
  delete_contents_on_destroy  = true

}