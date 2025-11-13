#!/bin/bash
# 05_setup_service_v1.sh
# Sets up demos-node as a systemd service

set -euo pipefail

MARKER="/root/.demos_node_setup/05_setup_service_v1.done"
SERVICE_NAME="demos-node"
TARGET_DIR="/opt/demos-node"

if [ -f "$MARKER" ]; then
  echo "✅ Service already configured. Skipping."
  exit 0
fi

echo "🛠️ Creating systemd service for demos-node..."

cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=Demos Node Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$TARGET_DIR
ExecStart=/root/.bun/bin/bun start
Restart=always
User=root
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Reloading systemd and enabling service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

echo "🔍 Checking service status..."
systemctl status $SERVICE_NAME --no-pager || true

touch "$MARKER"
echo "✅ Service setup complete."