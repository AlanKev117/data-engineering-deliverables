output "public_subnet" {
  value = google_compute_subnetwork.public_subnets.*.id
}

output "private_subnets" {
  value = google_compute_subnetwork.private_subnets.*.id
}

output "vpc" {
  value = google_compute_network.main-vpc.id
}

output "private_network_id" {
  value = google_compute_network.main-vpc.id
}

output "address_name" {
  value = google_compute_global_address.private_ip_address.name
}

output "private_network_name" {
  value = google_compute_network.main-vpc.name
}

output "private_subnetwork_name" {
  value = google_compute_subnetwork.private_subnets[0].name
}