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
        echo "wget not found. Installing wget..."
        sudo apt-get update -y && sudo apt-get install wget -y || { echo "Failed to install wget"; exit 1; }
      else
        echo "wget is already available."
      fi

      if ! command -v unzip &> /dev/null; then
        echo "unzip not found. Installing unzip..."
        sudo apt-get update -y && sudo apt-get install unzip -y || { echo "Failed to install unzip"; exit 1; }
      else
        echo "unzip is already available."
      fi
      
      # Install AWS CLI locally if not present
      if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Installing AWS CLI..."
        wget -q "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip"
        unzip -q awscliv2.zip || { echo "Failed to unzip AWS CLI package"; exit 1; }
        sudo ./aws/install || { echo "Failed to install AWS CLI"; exit 1; }
        rm -rf awscliv2.zip aws
      else
        echo "AWS CLI is already available."
      fi
      
      # Install kubectl locally if not present
      if [ ! -f "./kubectl" ]; then
        echo "Installing kubectl locally..."
        wget   "wget "https://storage.googleapis.com/kubernetes-release/release/v1.28.2/bin/linux/amd64/kubectl"
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

      # Ensure AWS CLI is installed
      if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install AWS CLI and rerun."
        exit 1
      fi

      # Write the kubeconfig to a file
      echo "${local.extracted_kubeconfig}" > kubeconfig.yaml

      # Verify installations
      echo "Verifying installations..."
      ./kubectl version --client > /dev/null || { echo "kubectl verification failed"; exit 1; }
      ./jq --version > /dev/null || { echo "jq verification failed"; exit 1; }
      aws --version > /dev/null || { echo "AWS CLI verification failed"; exit 1; }

      echo "All tools installed and verified locally."

      # Apply the bootstrap YAML using local kubectl
      echo "Applying bootstrap YAML using local kubectl..."
      ./kubectl --kubeconfig=kubeconfig.yaml apply -f - <<EOF
${rafay_import_cluster.import_cluster.bootstrap_data}
EOF
    EOT
  }
}
