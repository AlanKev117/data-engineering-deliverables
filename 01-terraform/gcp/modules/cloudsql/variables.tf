variable "region" {
  description = "Region where the instance will live"
}

variable "location" {
  description = "The preferred compute engine"
}

variable "instance_name" {
  description = "Name for the sql instance database"
}

variable "database_version" {
  description = "The MySQL, PostgreSQL or SQL Server (beta) version to use. "
}

variable "instance_tier" {
  description = "Sql instance tier"
  default = "db-f1-micro"
}

variable "disk_space" {
  description = "Size of the disk in the sql instance"
}

variable "database_name" {
  description = "Name for the database to be created"
}

variable "db_username" {
  description = "Username credentials for new user"
}
variable "private_network_id" {
  description = "Private network ID"
}

variable "address_name" {
  description = "Name of the google_compute_global_address resource"
}
