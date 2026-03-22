#!/bin/bash

set -e # Exit immediatel if a command exists with a non-zero status
set -o pipefail # Return the exit status of the last command in the pipe that failed

echo "Installing Docker, KIND, and Kubectl..."

# Install Docker
if ! command -v docker &>/dev/null; then
    echo "Docker not found, installing docker..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io

    # Add current user to docker group to run docker without sudo
    sudo usermod -aG docker $USER && newgrp docker
    echo "Docker installed successfully and user added to docker group. Please log out and log back in for changes to take effect."
else
    echo "Docker is already installed."
fi

# Install KIND
if ! command -v kind &>/dev/null; then
    echo "KIND not found, installing KIND..."

    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-$(uname)-amd64
    elif [[ "$ARCH" == "aarch64" ]]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-$(uname)-arm64
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi

    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "KIND installed successfully."
else
    echo "KIND is already installed."
fi

# Install kubectl
if ! command -v kubectl &>/dev/null; then
  echo "📦 Installing kubectl (latest stable version)..."

  ARCH=$(uname -m)
  VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

  if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
  elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/arm64/kubectl"
  else
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
  fi

  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  echo "✅ kubectl installed successfully."
else
  echo "✅ kubectl is already installed."
fi

# ----------------------------
# 4. Confirm Versions
# ----------------------------
echo
echo "🔍 Installed Versions:"
docker --version
kind --version
kubectl version --client --output=yaml

echo
echo "🎉 Docker, Kind, and kubectl installation complete!"
