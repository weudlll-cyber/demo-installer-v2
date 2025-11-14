#!/bin/bash
# This script installs Bun, a fast JavaScript runtime used by Demos Node.
# It ensures Bun is installed, added to PATH, and verified before continuing.

set -euo pipefail
IFS=$'\n\t'

echo -e "\e[91m🔧 [03] Installing Bun JavaScript runtime...\e[0m"
echo -e "\e[91mBun is required to run and manage the Demos Node efficiently.\e[0m"

MARKER_DIR="/root/.demos_node_setup"
STEP_MARKER="$MARKER_DIR/03_install_bun.done"
mkdir -p "$MARKER_DIR"

# === Skip if already completed ===
if [ -f "$STEP_MARKER" ]; then
  echo -e "\e[91m✅ [03] Bun installation already completed. Skipping...\e[0m"
  exit 0
fi

# === Install unzip (required by Bun installer) ===
echo -e "\e[91m🔍 Checking for unzip (required by Bun installer)...\e[0m"
if ! command -v unzip &>/dev/null; then
  echo -e "\e[91m📦 unzip not found. Installing...\e[0m"
  apt-get update && apt-get install -y unzip || {
    echo -e "\e[91m❌ unzip installation failed.\e[0m"
    echo -e "\e[91mRun manually:\e[0m"
    echo -e "\e[91msudo apt-get install -y unzip\e[0m"
    echo -e "\e[91mThen restart the installer:\e[0m"
    echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
    exit 1
  }
fi
echo -e "\e[91m✅ unzip is installed.\e[0m"

# === Install Bun ===
echo -e "\e[91m📥 Downloading and installing Bun...\e[0m"
curl -fsSL https://bun.sh/install | bash || {
  echo -e "\e[91m❌ Bun installation failed.\e[0m"
  echo -e "\e[91mRun manually:\e[0m"
  echo -e "\e[91mcurl -fsSL https://bun.sh/install | bash\e[0m"
  echo -e "\e[91mThen restart the installer:\e[0m"
  echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
  exit 1
}

# === Add Bun to PATH ===
echo -e "\e[91m🔧 Adding Bun to PATH...\e[0m"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# === Verify Bun installation ===
echo -e "\e[91m🔍 Verifying Bun installation...\e[0m"
if [ -x "$HOME/.bun/bin/bun" ]; then
  echo -e "\e[91m✅ Bun is installed and executable.\e[0m"
  touch "$STEP_MARKER"
else
  echo -e "\e[91m❌ Bun binary not found after installation.\e[0m"
  echo -e "\e[91mRun manually:\e[0m"
  echo -e "\e[91mcurl -fsSL https://bun.sh/install | bash\e[0m"
  echo -e "\e[91mThen restart the installer:\e[0m"
  echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
  exit 1
fi
