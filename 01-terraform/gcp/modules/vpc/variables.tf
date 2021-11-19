# --- variables.tf/gcp/modules/vpc

variable "project_id" {}
/*
variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}
variable "cidr_range" {
  description = "CIDR range to create the subnets"
  type        = number
}*/
variable "private_subnet_name" {
  description = "Subnet name"
  type        = list(string)
  default     = [
    "private-0",
    "private-1",
    "private-2",
    # "private-3",
    # "private-4",
    # "private-5",
    # "private-6",
    ]
}
variable "public_subnet_name" {
  description = "Subnet name"
  type        = list(string)
  default     = [
    "public-0",
    "public-1",
    "public-2",
    # "public-3",
    # "public-4",
    # "public-5",
    # "public-6",
    ]
}

variable "private_subnets" {
  description = "Private Subnets IP addresses"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    # "10.128.4.0/24",
    # "10.128.5.0/24",
    # "10.128.6.0/24",
    # "10.128.7.0/24",
    ]
}

variable "public_subnets" {
  description = "Public Subnets IP addresses"
  type        = list(string)
  default     = [
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    # "10.128.11.0/24",
    # "10.128.12.0/24",
    # "10.128.13.0/24",
    # "10.128.14.0/24",
    ]
}