#!/bin/bash
# Enforce strict error handling: exit on error, undefined variables, and pipeline failures
set -euo pipefail
IFS=$'\n\t'

# === STARTUP ===
echo -e "\e[91mStarting Demos Node Installer...\e[0m"

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\e[91m❌ This script must be run as root.\e[0m"
  echo -e "\e[91mPlease run:\e[0m"
  echo -e "\e[91msudo bash demos_node_setup_v1.sh\e[0m"
  exit 1
fi

# Create marker directory to track completed steps
MARKER_DIR="/root/.demos_node_setup"
mkdir -p "$MARKER_DIR"

# Prevent concurrent execution
LOCK_FILE="$MARKER_DIR/installer.lock"
if [ -f "$LOCK_FILE" ]; then
  echo -e "\e[91m❌ Installer is already running or was interrupted.\e[0m"
  echo -e "\e[91mTo retry, run:\e[0m"
  echo -e "\e[91mrm -f $LOCK_FILE\e[0m"
  exit 1
fi
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Sanitize environment: remove proxy variables that could interfere with downloads
unset $(env | grep -E '^(http_proxy|https_proxy|no_proxy)=' | cut -d= -f1)

# === STEP 00: Repair dpkg if interrupted ===
if [ -f /var/lib/dpkg/lock ] || [ -f /var/lib/dpkg/lock-frontend ]; then
  echo -e "\e[91m🔒 dpkg lock detected. Waiting for other processes to finish...\e[0m"
  sleep 10
fi

if dpkg --audit | grep -q .; then
  echo -e "\e[91m⚠️ dpkg was interrupted. Attempting automatic repair...\e[0m"
  echo -e "\e[91mIf this fails, run manually:\e[0m"
  echo -e "\e[91msudo dpkg --configure -a\e[0m"
  dpkg --configure -a
  echo -e "\e[91m✅ dpkg repair completed.\e[0m"
fi

# === STEP 01: DNS Check ===
if [ ! -f "$MARKER_DIR/01_dns_check.done" ]; then
  echo -e "\e[91m[STEP 01] Checking GitHub DNS...\e[0m"
  until ping -c1 github.com &>/dev/null; do
    echo -e "\e[91mWaiting for GitHub DNS resolution...\e[0m"
    sleep 5
  done
  touch "$MARKER_DIR/01_dns_check.done"
  echo -e "\e[91m✅ GitHub DNS resolved.\e[0m"
else
  echo -e "\e[91m[STEP 01] Already completed.\e[0m"
fi

# === STEP 02: Install Docker ===
if [ ! -f "$MARKER_DIR/02_install_docker.done" ]; then
  echo -e "\e[91m[STEP 02] Installing Docker...\e[0m"
  apt-get update && apt-get install -y docker.io
  systemctl enable docker && systemctl start docker
  if command -v docker >/dev/null 2>&1; then
    touch "$MARKER_DIR/02_install_docker.done"
    echo -e "\e[91m✅ Docker installed successfully.\e[0m"
  else
    echo -e "\e[91m❌ Docker installation failed.\e[0m"
    echo -e "\e[91mTry manually:\e[0m"
    echo -e "\e[91msudo apt-get install -y docker.io\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 02] Already completed.\e[0m"
fi

# === STEP 03: Install Bun ===
if [ ! -f "$MARKER_DIR/03_install_bun.done" ]; then
  echo -e "\e[91m[STEP 03] Installing Bun (JavaScript runtime)...\e[0m"
  apt-get install -y unzip
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
  echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc
  if [ -x "$HOME/.bun/bin/bun" ]; then
    touch "$MARKER_DIR/03_install_bun.done"
    echo -e "\e[91m✅ Bun installed successfully.\e[0m"
  else
    echo -e "\e[91m❌ Bun installation failed.\e[0m"
    echo -e "\e[91mTry manually:\e[0m"
    echo -e "\e[91mcurl -fsSL https://bun.sh/install | bash\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 03] Already completed.\e[0m"
fi

# === STEP 04: Clone Node Repository ===
if [ ! -f "$MARKER_DIR/04_clone_repo.done" ]; then
  echo -e "\e[91m[STEP 04] Cloning Demos Node repository...\e[0m"
  if [ -d "/opt/demos-node/.git" ]; then
    echo -e "\e[91mRepo already exists. Skipping clone.\e[0m"
  else
    rm -rf /opt/demos-node 2>/dev/null || true
    git clone https://github.com/kynesyslabs/node.git /opt/demos-node
  fi
  cd /opt/demos-node
  bun install
  if [ -f "run" ]; then
    touch "$MARKER_DIR/04_clone_repo.done"
    echo -e "\e[91m✅ Node repository cloned and dependencies installed.\e[0m"
  else
    echo -e "\e[91m❌ Node setup failed. Missing run script.\e[0m"
    echo -e "\e[91mCheck manually:\e[0m"
    echo -e "\e[91mls -l /opt/demos-node/run\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 04] Already completed.\e[0m"
fi

# === STEP 05: Create Systemd Service ===
if [ ! -f "$MARKER_DIR/05_systemd_service.done" ]; then
  echo -e "\e[91m[STEP 05] Creating systemd service for Demos Node...\e[0m"
  cat > /etc/systemd/system/demos-node.service <<EOF
[Unit]
Description=Demos Node Service
After=network.target

[Service]
ExecStart=/opt/demos-node/run
Restart=always
User=root
Environment=NODE_ENV=production
WorkingDirectory=/opt/demos-node
Environment=PATH=/root/.bun/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable demos-node.service
  systemctl start demos-node.service
  sleep 2
  if systemctl is-active --quiet demos-node.service; then
    touch "$MARKER_DIR/05_systemd_service.done"
    echo -e "\e[91m✅ Demos Node service is running.\e[0m"
  else
    echo -e "\e[91m❌ Service failed to start.\e[0m"
    echo -e "\e[91mCheck status manually:\e[0m"
    echo -e "\e[91msystemctl status demos-node.service --no-pager -l\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 05] Already completed.\e[0m"
fi

# === STEP 06: Install Helper Scripts ===
if [ ! -f "$MARKER_DIR/06_install_helpers.done" ]; then
  echo -e "\e[91m[STEP 06] Installing helper scripts from GitHub...\e[0m"
  if curl -fsSL https://raw.githubusercontent.com/weudlll-cyber/demos-installer-v2/main/install_helpers_v1.sh | bash; then
    touch "$MARKER
