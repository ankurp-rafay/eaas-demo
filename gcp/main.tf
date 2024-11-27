# Configure the Google Cloud provider
provider "google" {
  project = var.project_id  # Use the variable for project ID
  region  = var.region      # Use the variable for region
}

# Create a Google Compute Firewall
resource "google_compute_firewall" "instance" {
  name    = var.firewall_name   # Use the variable for firewall name
  network = "default"

  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }
}

# Create a Google Compute instance
resource "google_compute_instance" "example" {
  name          = var.vm_name       # Use the variable for VM name
  machine_type  = var.machine_type  # Use the variable for machine type
  zone          = var.zone          # Use the variable for zone
  
  boot_disk {
    initialize_params {
      image = var.image            # Use the variable for image
    }
  }
  
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
  
  tags = var.vm_tags               # Use the variable for VM tags


  dynamic "confidential_instance_config" {
    for_each = var.enable_confidential_compute ? [1] : []
    content {
      enable_confidential_compute = var.enable_confidential_compute
    }
  }
  
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y nginx

    # Configure NGINX to listen on the specified port
    sed -i "s/listen 80 default_server;/listen ${var.server_port} default_server;/g" /etc/nginx/sites-available/default
    sed -i "s/listen \\[::\\]:80 default_server;/listen \\[::\\]:${var.server_port} default_server;/g" /etc/nginx/sites-available/default

    echo '<!DOCTYPE html>
    <html>
    <head>
      <title>Welcome to NGINX</title>
    </head>
    <body>
      <h1>Hello from NGINX on Port ${var.server_port}!</h1>
    </body>
    </html>' > /var/www/html/index.html

    systemctl enable nginx
    systemctl restart nginx
  EOT
}
