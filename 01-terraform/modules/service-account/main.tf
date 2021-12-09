resource "google_service_account" "automation" {
  account_id   = "automation"
  display_name = "A service account for automation purposes"
}

resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.automation.email}"
}

resource "google_service_account_key" "mykey" {
  service_account_id = google_service_account.automation.name
}