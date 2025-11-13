#!/bin/bash
# 01_prepare_system_v1.sh
# Prepares the system by updating packages and installing basic dependencies

set -euo pipefail

MARKER="/root/.demos_node_setup/01_prepare_system_v1.done"

if [ -f "$MARKER" ]; then
  echo "✅ System preparation already completed. Skipping."
  exit 0
fi

echo "🔧 Updating system packages..."
apt-get update -y
apt-get upgrade -y

echo "📦 Installing basic dependencies..."
apt-get install -y curl wget git unzip build-essential

echo "🧪 Verifying installations..."
command -v curl && echo "✔ curl installed"
command -v git && echo "✔ git installed"

touch "$MARKER"
echo "✅ System preparation complete."