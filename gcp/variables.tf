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
  default     = "us-central1"
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

variable "enable_confidential_compute" {
  type        = bool
  description = "Flag to enable Confidential VM (Confidential Compute)"
  default     = false
}

variable "vm_tags" {
  type        = list(string)
  description = "Tags assigned to the virtual machine"
  default     = ["terraform-example"]
}


variable "firewall_name" {
  type        = string
  description = "Name of the firewall rule"
  default     = "terraform-example-instance"
}

variable "network_name" {
  type        = string
  description = "Name of the custom network"
  default     = "custom-network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the custom subnet"
  default     = "custom-subnet"
}

variable "subnet_cidr_range" {
  type        = string
  description = "CIDR range for the custom subnet"
  default     = "10.0.0.0/24"
}

variable "server_source_ranges" {
  type        = list(string)
  description = "Source ranges for server traffic"
  default     = ["0.0.0.0/0"]
}


variable "ssh_source_ranges" {
  type        = list(string)
  description = "Source ranges for SSH traffic"
  default     = ["0.0.0.0/0"]
}

variable "iap_source_ranges" {
  type        = list(string)
  description = "Source ranges for IAP traffic"
  default     = ["35.235.240.0/20"]
}


variable "enable_server_access" {
  type        = bool
  description = "Enable server access firewall rules"
  default     = true
}

variable "enable_ssh" {
  type        = bool
  description = "Enable SSH firewall rules"
  default     = true
}

variable "enable_http_https" {
  type        = bool
  description = "Enable HTTP and HTTPS firewall rules"
  default     = true
}

