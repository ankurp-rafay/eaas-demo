# Output variable: Public IP address
output "public_ip" {
  value = google_compute_instance.example.network_interface[0].access_config[0].nat_ip
}


output "server_port" {
  value = var.server_port
  description = "Port on which the server is listening"
}
