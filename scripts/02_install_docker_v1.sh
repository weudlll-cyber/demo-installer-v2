#!/bin/bash
# 02_install_docker_v1.sh
# Installs Docker and Docker Compose

set -euo pipefail

MARKER="/root/.demos_node_setup/02_install_docker_v1.done"

if [ -f "$MARKER" ]; then
  echo "✅ Docker already installed. Skipping."
  exit 0
fi

echo "🐳 Installing Docker..."

# Remove old versions if any
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Install using official convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

echo "🔧 Adding user to docker group..."
usermod -aG docker "${SUDO_USER:-$USER}"

echo "🔍 Verifying Docker installation..."
docker --version && echo "✔ Docker installed"
docker compose version || echo "ℹ️ Docker Compose not found — installing..."

# Install Docker Compose if missing
if ! command -v docker-compose &> /dev/null; then
  curl -fsSL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
fi

docker compose version && echo "✔ Docker Compose installed"

touch "$MARKER"
echo "✅ Docker setup complete."