variable "cluster_name" {
  type = string
}

variable "project_name" {
  description = "Rafay Project Name"
  type = string
}

variable "blueprint" {
  description = "Rafay blueprint Name"
  type = string
}
variable "blueprint_version" {
  description = "Rafay blueprint Version"
  type = string
}
variable "kubernetes_provider" {
  description = "Name of the K8s cloud provider, ex: EKS,AKS,GKE,OPENSHIFT,RKE,EKSANYWHERE,OTHER"
  type = string
}

variable "provision_environment" {
  description = "type of environment, ex: CLOUD, ONPREM"
  type = string
}

variable "kubeconfig" {
  type        = string

  validation {
    condition     = can(jsondecode(var.kubeconfig)) || length(var.kubeconfig) > 0
    error_message = "The kubeconfig must be either a valid JSON object with a 'value' key or a raw YAML string."
  }
}

