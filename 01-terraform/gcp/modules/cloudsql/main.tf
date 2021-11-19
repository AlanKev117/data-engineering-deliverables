resource "google_sql_database_instance" "sql_instance" {
  provider = google-beta
  project = var.project_id
  name              = "temp-instance-${random_id.db_name_suffix.hex}"
  database_version  = var.database_version

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.instance_tier
    disk_size = var.disk_space
    ip_configuration {
      ipv4_enabled    = true
      private_network = var.private_network_id
    }
  }

  deletion_protection = "false"
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.sql_instance.name
}

resource "google_sql_user" "users" {
  name     = var.db_username
  instance = google_sql_database_instance.sql_instance.name
  password = random_password.sql_password.result
}

# Helpers

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

provider "google-beta" {
  region = var.region
  zone   = var.location
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = var.private_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [var.address_name]
}
