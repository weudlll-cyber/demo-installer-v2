#!/bin/bash
# demos_node_setup_v1.sh
# Modular installer for demos-node using version map v1

set -euo pipefail

# GitHub repo info — replace with your actual username and repo
GITHUB_USER="weudlll-cyber"
GITHUB_REPO="demos-installer-v2"

# Use fixed version v1
HELPER_VERSION="v1"
MAP_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/version_map/${HELPER_VERSION}.txt"
HELPER_BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main/scripts"

HELPER_DIR="/root/demos_helpers"
MARKER_DIR="/root/.demos_node_setup"
mkdir -p "$HELPER_DIR" "$MARKER_DIR"

# Download version map
VERSION_MAP="$HELPER_DIR/version_map.txt"
curl -fsSL "$MAP_URL" -o "$VERSION_MAP"

# Read and run each mapped script
while IFS='=' read -r step script_file; do
  LOCAL_PATH="$HELPER_DIR/$script_file"
  REMOTE_URL="$HELPER_BASE_URL/$script_file"

  echo "🔍 Checking $script_file for updates..."

  if [ -f "$LOCAL_PATH" ]; then
    curl -fsz "$LOCAL_PATH" "$REMOTE_URL" -o "$LOCAL_PATH"
    echo "📁 $script_file checked — updated if needed."
  else
    curl -fsSL "$REMOTE_URL" -o "$LOCAL_PATH"
    echo "📥 $script_file downloaded for the first time."
  fi

  chmod +x "$LOCAL_PATH"
  echo "🚀 Running $script_file..."
  bash "$LOCAL_PATH"
done < "$VERSION_MAP"

echo "🎉 All setup steps completed."
