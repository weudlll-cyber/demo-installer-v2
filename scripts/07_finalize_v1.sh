#!/bin/bash
# This script completes the Demos Node installation and reminds the user how to manage the node.

set -euo pipefail
IFS=$'\n\t'

echo -e "\e[91m🎉 [07] Finalizing installation...\e[0m"
echo -e "\e[91mYou're almost done! Let's wrap things up.\e[0m"

MARKER_DIR="/root/.demos_node_setup"
STEP_MARKER="$MARKER_DIR/07_finalize.done"
mkdir -p "$MARKER_DIR"

# === Skip if already completed ===
if [ -f "$STEP_MARKER" ]; then
  echo -e "\e[91m✅ [07] Finalization already completed. Skipping...\e[0m"
  exit 0
fi

# === Final messages ===
echo -e "\e[91m✅ Demos Node is now fully installed and running as a systemd service.\e[0m"
echo -e "\e[91mYou can manage it using the helper tools installed:\e[0m"
echo -e "\e[91m🔍 Check status:\e[0m"
echo -e "\e[91mcheck_demos_node --status\e[0m"
echo -e "\e[91m🔄 Restart node:\e[0m"
echo -e "\e[91mrestart_demos_node\e[0m"
echo -e "\e[91m📦 View logs:\e[0m"
echo -e "\e[91msudo journalctl -u demos-node --no-pager --since \"10 minutes ago\"\e[0m"

touch "$STEP_MARKER"
