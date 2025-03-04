resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Installing curl and jq without requiring root access..."

      # Create a local bin directory and add it to PATH
      mkdir -p "$HOME/bin"
      export PATH="$HOME/bin:$PATH"

      # Install curl
      if ! command -v curl > /dev/null; then
        echo "Downloading and installing curl..."
        wget -qO "$HOME/bin/curl" https://github.com/moparisthebest/static-curl/releases/latest/download/curl-amd64
        chmod +x "$HOME/bin/curl"
      else
        echo "curl is already installed."
      fi

      # Install jq
      if ! command -v jq > /dev/null; then
        echo "Downloading and installing jq..."
        wget -qO "$HOME/bin/jq" https://github.com/stedolan/jq/releases/latest/download/jq-linux64
        chmod +x "$HOME/bin/jq"
      else
        echo "jq is already installed."
      fi

      # Confirm installations
      "$HOME/bin/curl" --version && "$HOME/bin/jq" --version
    EOT
  }

  triggers = {
    install_trigger = timestamp()
  }
}


resource "null_resource" "execute_command" {
  provisioner "local-exec" {
    command = <<EOT
      # Set up the output directory
      OUTPUT_DIR="${path.module}/output"
      mkdir -p "$OUTPUT_DIR"
      OUTPUT_FILE="$OUTPUT_DIR/output.txt"

      # Ensure the correct PATH includes $HOME/bin
      export PATH="$HOME/bin:$PATH"

      # Check and make the script executable
      chmod +x "${path.module}/command_executor.sh"

      # Run the script
      bash "${path.module}/command_executor.sh" \
        "${var.base_url}" \
        "${var.api_key}" \
        "${var.project_name}" \
        "${var.cluster_name}" \
        "${var.command}" \
        "${var.timeout}" \
        "$OUTPUT_FILE"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [null_resource.install_dependencies]

  triggers = {
    command_trigger = timestamp()
    base_url        = var.base_url
    api_key         = var.api_key
    project_name    = var.project_name
    cluster_name    = var.cluster_name
    command         = var.command
    timeout         = var.timeout
  }
}

data "local_file" "command_output" {
  depends_on = [null_resource.execute_command]
  filename   = "${path.module}/output/output.txt"
}
