# --- main.tf/gcp/modules/vpc ---

resource "google_compute_network" "main-vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnets" {
  count = length(var.private_subnets)
  name  = "${var.private_subnet_name[count.index]}-private-subnet"

  ip_cidr_range = var.private_subnets[count.index]
  network       = google_compute_network.main-vpc.id

}

resource "google_compute_subnetwork" "public_subnets" {
  count         = length(var.public_subnets)
  name          = "${var.public_subnet_name[count.index]}-public-subnet"
  ip_cidr_range = var.public_subnets[count.index]
  network       = google_compute_network.main-vpc.id
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main-vpc.id
}


provider "google-beta" {
  region = "us-central1"
  zone   = "us-central1-a"
}

resource "google_compute_firewall" "dpfirewall" {
  name    = "dataproc-allow-internal"
  network = google_compute_network.main-vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  direction = "INGRESS"

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }

  source_ranges = ["10.0.0.0/16"]
}
