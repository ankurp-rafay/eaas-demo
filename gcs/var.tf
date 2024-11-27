variable "bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
  default     = "demo-gcs"
}

variable "bucket_location" {
  description = "The location/region for the GCS bucket"
  type        = string
  default     = "us-central1"
}

variable "storage_class" {
  description = "The storage class of the GCS bucket"
  type        = string
  default     = "STANDARD"
}

variable "enable_versioning" {
  description = "Flag to enable versioning on the GCS bucket"
  type        = bool
  default     = false
}

variable "lifecycle_age" {
  description = "Number of days after which objects are deleted"
  type        = number
  default     = 365
}

variable "environment" {
  description = "Environment label for the GCS bucket"
  type        = string
  default     = "dev"
}

variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
  default     = "demos-249423"
}
