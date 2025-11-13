#!/bin/bash
# 06_create_helpers_v1.sh
# Creates helper scripts or symlinks for easier management

set -euo pipefail

MARKER="/root/.demos_node_setup/06_create_helpers_v1.done"
HELPER_BIN="/usr/local/bin"

if [ -f "$MARKER" ]; then
  echo "✅ Helper scripts already created. Skipping."
  exit 0
fi

echo "🔧 Creating helper commands..."

# Example: create a shortcut to restart the demos-node service
cat <<EOF > "$HELPER_BIN/restart-node"
#!/bin/bash
systemctl restart demos-node
EOF

chmod +x "$HELPER_BIN/restart-node"
echo "✔ Created: restart-node"

# Example: create a shortcut to check service status
cat <<EOF > "$HELPER_BIN/status-node"
#!/bin/bash
systemctl status demos-node --no-pager
EOF

chmod +x "$HELPER_BIN/status-node"
echo "✔ Created: status-node"

touch "$MARKER"
echo "✅ Helper commands created."