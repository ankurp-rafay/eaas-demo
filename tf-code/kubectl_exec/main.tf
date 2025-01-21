resource "rafay_download_kubeconfig" "tfkubeconfig" {
  cluster            = var.cluster_name
  output_folder_path = "/tmp"
  filename           = "kubeconfig.yaml"
}

resource "null_resource" "install_kubectl" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Downloading kubectl..."
      mkdir -p "$HOME/bin"
      wget -q "https://storage.googleapis.com/kubernetes-release/release/v1.28.2/bin/linux/amd64/kubectl" -O "$HOME/bin/kubectl"
      chmod +x "$HOME/bin/kubectl"
      echo "kubectl installed successfully."
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "kubectl_cmds" {
  depends_on = [
    rafay_download_kubeconfig.tfkubeconfig,
    null_resource.install_kubectl
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "export PATH=\"$HOME/bin:$PATH\" && kubectl --kubeconfig=/tmp/kubeconfig get pods -A > \"${path.module}/kubectl_output.txt\""
  }

  triggers = {
    command_trigger = timestamp()
    cluster_name    = var.cluster_name
  }
}

data "local_file" "kubectl_output" {
  depends_on = [null_resource.kubectl_cmds]
  filename   = "${path.module}/kubectl_output.txt"
}

