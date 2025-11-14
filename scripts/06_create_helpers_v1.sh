#!/bin/bash
# This script installs helper tools for managing the Demos Node.
# These include commands like `check_demos_node` and `restart_demos_node`.

set -euo pipefail
IFS=$'\n\t'

echo -e "\e[91m🔧 [06] Installing helper tools for Demos Node management...\e[0m"
echo -e "\e[91mThese tools make it easier to check status and restart the node manually.\e[0m"

MARKER_DIR="/root/.demos_node_setup"
STEP_MARKER="$MARKER_DIR/06_create_helpers.done"
mkdir -p "$MARKER_DIR"

# === Skip if already completed ===
if [ -f "$STEP_MARKER" ]; then
  echo -e "\e[91m✅ [06] Helper tools already installed. Skipping...\e[0m"
  exit 0
fi

# === Define helper script URLs ===
HELPER_BASE_URL="https://raw.githubusercontent.com/weudlll-cyber/demos-installer-v2/main/helpers"
HELPERS=("check_demos_node" "restart_demos_node")

# === Install each helper ===
for helper in "${HELPERS[@]}"; do
  echo -e "\e[91m📥 Installing helper: $helper...\e[0m"
  curl -fsSL "$HELPER_BASE_URL/$helper" -o "/usr/local/bin/$helper" || {
    echo -e "\e[91m❌ Failed to download $helper.\e[0m"
    echo -e "\e[91mCheck your internet connection or GitHub access.\e[0m"
    echo -e "\e[91mTry manually:\e[0m"
    echo -e "\e[91mcurl -fsSL $HELPER_BASE_URL/$helper -o /usr/local/bin/$helper && chmod +x /usr/local/bin/$helper\e[0m"
    echo -e "\e[91mThen restart the installer:\e[0m"
    echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
    exit 1
  }

  chmod +x "/usr/local/bin/$helper" || {
    echo -e "\e[91m❌ Failed to make $helper executable.\e[0m"
    echo -e "\e[91mRun manually:\e[0m"
    echo -e "\e[91msudo chmod +x /usr/local/bin/$helper\e[0m"
    echo -e "\e[91mThen restart the installer:\e[0m"
    echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
    exit 1
  }

  echo -e "\e[91m✅ $helper installed successfully.\e[0m"
done

touch "$STEP_MARKER"
