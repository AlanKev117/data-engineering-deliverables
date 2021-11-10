output "instance_name" {
  value = google_sql_database_instance.sql_instance.name
}

output "instance_connection_name" {
  value = google_sql_database_instance.sql_instance.connection_name
}

output "instance_private_address" {
  value = google_sql_database_instance.sql_instance.private_ip_address
}

output "instance_ip_address" {
  value = google_sql_database_instance.sql_instance.ip_address
}

output "database_connection" {
  value = google_sql_database.database.self_link
}

output "database" {
  value = google_sql_database.database.id
}

output "db_user_name" {
  value = google_sql_user.users.name
}

output "db_user_password" {
  value = google_sql_user.users.password
  sensitive = true
}