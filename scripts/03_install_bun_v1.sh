#!/bin/bash
# 03_install_bun_v1.sh
# Installs Bun JavaScript runtime

set -euo pipefail

MARKER="/root/.demos_node_setup/03_install_bun_v1.done"

if [ -f "$MARKER" ]; then
  echo "✅ Bun already installed. Skipping."
  exit 0
fi

echo "🍞 Installing Bun..."

# Use official install script
curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH for current session
export BUN_INSTALL="/root/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

echo "🔍 Verifying Bun installation..."
bun --version && echo "✔ Bun installed"

touch "$MARKER"
echo "✅ Bun setup complete."