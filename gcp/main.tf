# Configure the Google Cloud provider
provider "google" {
  project = var.project_id  # Use the variable for project ID
  region  = var.region      # Use the variable for region
}

# Create a Google Compute Firewall
resource "google_compute_firewall" "instance" {
  name    = "terraform-example-instance"
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
  
  tags = ["terraform-example"]
  
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update
    apt install -y nginx
    echo '<!DOCTYPE html>
    <html>
    <head>
      <title>Welcome to NGINX</title>
    </head>
    <body>
      <h1>Hello from NGINX!</h1>
    </body>
    </html>' > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOT
}
