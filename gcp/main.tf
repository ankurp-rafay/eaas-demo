# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a custom network
resource "google_compute_network" "custom_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Create a custom subnet in the network
resource "google_compute_subnetwork" "custom_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr_range
  region        = var.region
  network       = google_compute_network.custom_network.self_link
}

# Firewall rule to allow traffic to the server port
resource "google_compute_firewall" "server_access" {
  name    = var.firewall_name
  network = google_compute_network.custom_network.name

  source_ranges = var.server_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }
}

# Firewall rule for SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.custom_network.name

  source_ranges = var.ssh_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]  # SSH port
  }
}

# Firewall rule to allow HTTP and HTTPS traffic
resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.custom_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
     source_ranges = var.ssh_source_ranges
}

# Firewall rule for IAP access
resource "google_compute_firewall" "iap_ssh" {
  name    = "iap-ssh-allow"
  network = google_compute_network.custom_network.name

  source_ranges = var.iap_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["22"]  # SSH port
  }
}

# Create a Google Compute instance
resource "google_compute_instance" "example" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network    = google_compute_network.custom_network.self_link
    subnetwork = google_compute_subnetwork.custom_subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  tags = var.vm_tags

  # Enable Confidential VM only if the flag is true
  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_compute ? [1] : []
    content {
      enable_confidential_compute = var.enable_confidential_compute
    }
  }

  # Startup script for NGINX
  metadata_startup_script = <<-EOT
    #!/bin/bash
    exec > /var/log/startup-script.log 2>&1
    set -x

    # Update package list and install NGINX
    apt-get update -q
    apt-get install -y nginx

    # Configure NGINX to listen on the specified port
    NGINX_CONF="/etc/nginx/sites-available/default"
    sed -i "s/listen 80 default_server;/listen ${var.server_port} default_server;/g" "$NGINX_CONF"
    sed -i "s/listen \\[::\\]:80 default_server;/listen \\[::\\]:${var.server_port} default_server;/g" "$NGINX_CONF"

    # Create a custom HTML page
    cat <<EOF > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <title>Welcome to NGINX</title>
    </head>
    <body>
      <h1>Hello from NGINX on Port ${var.server_port}!</h1>
    </body>
    </html>
    EOF

    # Enable and restart NGINX
    systemctl enable nginx
    systemctl restart nginx

    echo "Startup script completed successfully"
  EOT
}
