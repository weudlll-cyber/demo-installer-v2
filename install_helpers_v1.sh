#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo -e "\e[91mStarting Demos Node Installer...\e[0m"

MARKER_DIR="/root/.demos_node_setup"
mkdir -p "$MARKER_DIR"

# === STEP 00: Smart Kernel Reboot Check ===
if [ ! -f "$MARKER_DIR/00_kernel_check.done" ]; then
  CURRENT_KERNEL=$(uname -r)
  LATEST_KERNEL=$(dpkg -l | awk '/linux-image-[0-9]+/{print $2}' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+-[0-9]+' | sort -V | tail -n1 || true)

  if [[ -n "$LATEST_KERNEL" && "$CURRENT_KERNEL" != "$LATEST_KERNEL" ]]; then
    echo -e "\e[91m[STEP 00] A newer kernel ($LATEST_KERNEL) is installed but not active.\e[0m"
    echo -e "\e[91mSystem will reboot in 10 seconds to apply the kernel update.\e[0m"
    echo -e "\e[91mAfter reboot you must rerun this installer script to continue the setup.\e[0m"
    sleep 10
    touch "$MARKER_DIR/00_kernel_check.done"
    reboot
    exit 0
  else
    echo -e "\e[91m[STEP 00] Kernel already up to date.\e[0m"
    touch "$MARKER_DIR/00_kernel_check.done"
  fi
fi

# === STEP 01: Wait for DNS and GitHub ===
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
    exit 1
  fi
else
  echo -e "\e[91m[STEP 02] Already completed.\e[0m"
fi

# === STEP 03: Install Bun ===
if [ ! -f "$MARKER_DIR/03_install_bun.done" ]; then
  echo -e "\e[91m[STEP 03] Installing Bun...\e[0m"
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
    exit 1
  fi
else
  echo -e "\e[91m[STEP 03] Already completed.\e[0m"
fi

# === STEP 04: Clone Testnet Node Repo ===
if [ ! -f "$MARKER_DIR/04_clone_repo.done" ]; then
  echo -e "\e[91m[STEP 04] Cloning Testnet Node repository...\e[0m"
  if [ -d "/opt/demos-node/.git" ]; then
    echo -e "\e[91m[STEP 04] Repo already exists at /opt/demos-node. Skipping clone.\e[0m"
  else
    rm -rf /opt/demos-node 2>/dev/null || true
    git clone https://github.com/kynesyslabs/node.git /opt/demos-node
  fi
  cd /opt/demos-node
  bun install
  if [ -f "run" ]; then
    touch "$MARKER_DIR/04_clone_repo.done"
    echo -e "\e[91m✅ Repository cloned and dependencies installed.\e[0m"
  else
    echo -e "\e[91m❌ Node repo setup failed.\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 04] Already completed.\e[0m"
fi

# === STEP 05: Create Systemd Service ===
if [ ! -f "$MARKER_DIR/05_systemd_service.done" ]; then
  echo -e "\e[91m[STEP 05] Creating systemd service...\e[0m"
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
    echo -e "\e[91m❌ Demos Node service failed to start.\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 05] Already completed.\e[0m"
fi

# === STEP 06: Install Helper Scripts ===
if [ ! -f "$MARKER_DIR/06_install_helpers.done" ]; then
  echo -e "\e[91m[STEP 06] Installing helper scripts...\e[0m"
  if curl -fsSL https://raw.githubusercontent.com/weudl-cyber/demos-installer-v2/main/install_helpers_v1.sh | bash; then
    touch "$MARKER_DIR/06_install_helpers.done"
    echo -e "\e[91m✅ Helper scripts installed.\e[0m"
  else
    echo -e "\e[91m❌ Failed to install helper scripts.\e[0m"
    exit 1
  fi
else
  echo -e "\e[91m[STEP 06] Already completed.\e[0m"
fi

echo -e "\e[91m✅ Demos Node installation complete.\e[0m"
