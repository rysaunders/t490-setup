#!/bin/bash
set -euo pipefail

echo "[*] T490 Setup Script"
echo "====================="

# Load configuration if it exists
CONFIG_FILE="${HOME}/.t490-setup.conf"
if [ -f "$CONFIG_FILE" ]; then
  echo "[*] Loading configuration from $CONFIG_FILE"
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
else
  echo "[*] No custom configuration found. Using defaults."
  echo "    For custom settings, copy config.sample.conf to ~/.t490-setup.conf"
fi

# Basic update and Ansible install
echo "[*] Updating system and installing requirements..."
if ! sudo apt update && sudo apt upgrade -y; then
  echo "[!] Failed to update system. Please check your internet connection."
  exit 1
fi

if ! sudo apt install -y ansible git curl; then
  echo "[!] Failed to install required packages. Please check your system."
  exit 1
fi

# Clone setup repo if not already present
REPO_PATH="$HOME/t490-setup"
if [ ! -d "$REPO_PATH" ]; then
  echo "[*] Cloning setup repository..."
  if ! git clone https://github.com/rysaunders/t490-setup "$REPO_PATH"; then
    echo "[!] Failed to clone repository. Please check your internet connection."
    exit 1
  fi
fi

# Determine script location for relative calls
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Windows ISO download should be skipped
if [[ -z "${SKIP_WIN_ISO_DOWNLOAD:-}" ]]; then
  echo "[*] Downloading ISOs..."
  if ! bash ./download_win_isos.sh; then
    echo "[!] Warning: Failed to download ISOs. Continuing with setup."
  fi
else
  echo "[*] Skipping Windows ISO download (SKIP_WIN_ISO_DOWNLOAD is set)"
fi

# Check if VM creation should be skipped
if [[ -z "${SKIP_VM_CREATION:-}" ]]; then
  echo "[*] Ready to build Windows VM? (y/n)"
  read -r confirm
  if [[ $confirm == [yY] ]]; then
    if ! bash ./create_win_vm.sh; then
      echo "[!] Warning: Failed to create Windows VM. Continuing with setup."
    fi
  fi
else
  echo "[*] Skipping Windows VM creation (SKIP_VM_CREATION is set)"
fi

# Run the playbook
echo "[*] Running Ansible playbook..."
cd "$REPO_PATH"
if ! ansible-playbook setup.yml -K; then
  echo "[!] Ansible playbook failed. Please check the output above."
  exit 1
fi

echo "[✓] Setup completed successfully!"
