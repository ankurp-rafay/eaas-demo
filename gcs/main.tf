resource "google_storage_bucket" "my_bucket" {
  name          = var.bucket_name
  location      = var.bucket_location
  storage_class = var.storage_class
  project       = var.project_id

  versioning {
    enabled = var.enable_versioning
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = var.lifecycle_age
    }
  }

  labels = {
    environment = var.environment
  }
}
