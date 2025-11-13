#!/bin/bash
# 07_finalize_v1.sh
# Finalizes the setup process and offers optional reboot

set -euo pipefail

MARKER="/root/.demos_node_setup/07_finalize_v1.done"

if [ -f "$MARKER" ]; then
  echo "✅ Finalization already completed. Skipping."
  exit 0
fi

echo "🎯 Finalizing setup..."

# Optional cleanup or environment tweaks can go here
echo "🧹 Cleaning up temporary files..."
rm -rf /tmp/* || true

echo "📋 Summary of setup:"
ls /root/.demos_node_setup

echo "🟢 Setup complete. You may now use your node and helper commands."

touch "$MARKER"

# Optional reboot prompt
read -p "🔁 Reboot now to finalize environment? (y/N): " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
  echo "♻️ Rebooting..."
  reboot
else
  echo "🚪 You can reboot later manually if needed."
fi
