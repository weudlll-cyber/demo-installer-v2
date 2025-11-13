#!/bin/bash
# 04_clone_node_v1.sh
# Clones the demos-node repository from GitHub

set -euo pipefail

MARKER="/root/.demos_node_setup/04_clone_node_v1.done"
TARGET_DIR="/opt/demos-node"

if [ -f "$MARKER" ]; then
  echo "✅ demos-node already cloned. Skipping."
  exit 0
fi

echo "📦 Cloning demos-node repository..."

# Replace with your actual GitHub repo URL
REPO_URL="https://github.com/YOUR_USERNAME/demos-node