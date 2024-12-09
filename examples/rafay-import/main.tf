locals {
  extracted_kubeconfig = var.kubeconfig
}

resource "rafay_import_cluster" "import_cluster" {
  clustername           = var.cluster_name
  projectname           = var.project_name
  blueprint             = var.blueprint
  blueprint_version     = var.blueprint_version
  kubernetes_provider   = var.kubernetes_provider
  provision_environment = var.provision_environment
  lifecycle {
    ignore_changes = [
      bootstrap_path,
      values_path
    ]
  }
}

resource "null_resource" "setup_and_apply" {
  depends_on = [rafay_import_cluster.import_cluster]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      # Ensure wget and unzip are available
      if ! command -v wget &> /dev/null; then
        echo "wget not found. Please install wget and rerun."
        exit 1
      fi

      if ! command -v unzip &> /dev/null; then
        echo "unzip not found. Please install unzip and rerun."
        exit 1
      fi

      # Install kubectl locally if not present
      if [ ! -f "./kubectl" ]; then
        echo "Installing kubectl locally..."
        wget -q "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -O kubectl
        chmod +x kubectl || { echo "Failed to chmod kubectl"; exit 1; }
      else
        echo "kubectl is already present locally."
      fi

      # Install jq locally if not present
      if [ ! -f "./jq" ]; then
        echo "Installing jq locally..."
        wget -q "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64" -O jq
        chmod +x jq || { echo "Failed to chmod jq"; exit 1; }
      else
        echo "jq is already present locally."
      fi

      # Install aws-iam-authenticator locally if not present
      if [ ! -f "./aws-iam-authenticator" ]; then
        echo "Installing aws-iam-authenticator locally..."
        wget -q "https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator" -O aws-iam-authenticator
        chmod +x aws-iam-authenticator || { echo "Failed to chmod aws-iam-authenticator"; exit 1; }
      else
        echo "aws-iam-authenticator is already present locally."
      fi

      # Write the kubeconfig to a file and update ExecCredential version if needed
      echo "${local.extracted_kubeconfig}" | sed 's/client.authentication.k8s.io\/v1alpha1/client.authentication.k8s.io\/v1/' > kubeconfig.yaml

      # Verify installations
      echo "Verifying installations..."
      ./kubectl version --client > /dev/null || { echo "kubectl verification failed"; exit 1; }
      ./jq --version > /dev/null || { echo "jq verification failed"; exit 1; }
      ./aws-iam-authenticator help > /dev/null || { echo "aws-iam-authenticator verification failed"; exit 1; }

      echo "All tools installed and verified locally."

      # Apply the bootstrap YAML using local kubectl
      echo "Applying bootstrap YAML using local kubectl..."
      ./kubectl --kubeconfig=kubeconfig.yaml apply -f - <<EOF
${rafay_import_cluster.import_cluster.bootstrap_data}
EOF
    EOT
  }
}
