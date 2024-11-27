# Variable for the server port
variable "server_port" {
  type        = number
  description = "Port number to expose the instance"
  default     = 8080
}

# Variable for the VM name
variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
  default     = "example-vm"
}

# Variable for the project ID
variable "project_id" {
  type        = string
  description = "Google Cloud project ID"
  default     = "demos-249423"
}

# Variable for the region
variable "region" {
  type        = string
  description = "Region for the Google Cloud resources"
  default     = "us-central"
}

# Variable for the zone
variable "zone" {
  type        = string
  description = "Zone for the Google Cloud instance"
  default     = "us-central1-a"
}

# Variable for the machine type
variable "machine_type" {
  type        = string
  description = "Machine type for the Google Cloud instance"
  default     = "f1-micro"
}

# Variable for the boot image
variable "image" {
  type        = string
  description = "Boot image for the Google Cloud instance"
  default     = "ubuntu-2204-lts"
}
