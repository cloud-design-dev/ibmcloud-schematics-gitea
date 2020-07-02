output "root_db_password" {
  value = random_id.rootpass.hex
}

output "db_password" {
  value = random_id.dbpass.hex
}

