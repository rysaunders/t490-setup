#!/bin/bash
set -euo pipefail

# Load configuration if it exists
CONFIG_FILE="${HOME}/.t490-setup.conf"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

# CONFIGURATION with defaults
VM_NAME="${VM_NAME:-win10}"
ISO_DIR="${ISO_DIR:-$HOME/isos}"
RAM_MB="${RAM_MB:-8192}"
VCPUS="${VCPUS:-4}"
DISK_SIZE="${DISK_SIZE:-100}"  # in GB
ISO_PATH="${ISO_PATH:-$ISO_DIR/Win10_22H2_English_x64.iso}"
VIRTIO_ISO="${VIRTIO_ISO:-$ISO_DIR/virtio-win.iso}"
DISK_PATH="${DISK_PATH:-/var/lib/libvirt/images/${VM_NAME}.qcow2}"

# Check if required packages are installed
echo "[*] Checking virtualization tools..."
if ! command -v qemu-img >/dev/null || ! command -v virt-install >/dev/null; then
  echo "[!] Required virtualization tools not found."
  echo "    Please ensure qemu-kvm, libvirt-daemon-system, and virt-manager are installed."
  echo "    You can install them with: sudo apt install qemu-kvm libvirt-daemon-system virt-manager"
  exit 1
fi

# Check if user is part of required groups
if ! groups | grep -qE '(libvirt|kvm)'; then
  echo "[!] Warning: Current user may not be in libvirt or kvm groups."
  echo "    Consider running: sudo usermod -aG libvirt,kvm $(whoami)"
  echo "    You may need to log out and back in for group changes to take effect."
fi

# Ensure ISO files exist
if [ ! -f "$ISO_PATH" ]; then
  echo "[!] Windows ISO not found at $ISO_PATH"
  echo "    Please run download_win_isos.sh first."
  exit 1
fi

if [ ! -f "$VIRTIO_ISO" ]; then
  echo "[!] VirtIO drivers ISO not found at $VIRTIO_ISO"
  echo "    Please run download_win_isos.sh first."
  exit 1
fi

# Check if VM already exists
if virsh dominfo "$VM_NAME" &>/dev/null; then
  echo "[!] A VM named '$VM_NAME' already exists."
  read -rp "Do you want to remove it and create a new one? (y/n): " confirm
  if [[ $confirm == [yY] ]]; then
    echo "[*] Removing existing VM '$VM_NAME'..."
    virsh destroy "$VM_NAME" &>/dev/null || true
    virsh undefine "$VM_NAME" --remove-all-storage || {
      echo "[!] Failed to remove existing VM."
      exit 1
    }
  else
    echo "[*] Keeping existing VM. Exiting."
    exit 0
  fi
fi

# Ensure libvirt images directory exists
DISK_DIR="$(dirname "$DISK_PATH")"
if [ ! -d "$DISK_DIR" ]; then
  echo "[*] Creating directory for VM disk..."
  sudo mkdir -p "$DISK_DIR" || {
    echo "[!] Failed to create disk directory. Check permissions."
    exit 1
  }
  sudo chown "$(whoami)":"$(whoami)" "$DISK_DIR" || true
fi

# Create disk image
echo "[*] Creating virtual disk..."
if ! qemu-img create -f qcow2 "$DISK_PATH" "${DISK_SIZE}G"; then
  echo "[!] Failed to create disk image. Check permissions and disk space."
  exit 1
fi

# Launch VM install
echo "[*] Launching virt-install..."
if ! virt-install \
  --name "$VM_NAME" \
  --ram "$RAM_MB" \
  --vcpus "$VCPUS" \
  --cpu host \
  --os-type windows \
  --os-variant win10 \
  --disk path="$DISK_PATH",format=qcow2,bus=virtio \
  --disk path="$VIRTIO_ISO",device=cdrom \
  --cdrom "$ISO_PATH" \
  --network network=default,model=virtio \
  --graphics spice \
  --sound ich9 \
  --video qxl \
  --boot useserial=on \
  --noautoconsole; then
  echo "[!] Failed to create VM. Check the error messages above."
  exit 1
fi

echo "[✓] VM created successfully. Launch it via virt-manager or virsh."
echo "    You can start the VM with: virsh start $VM_NAME"
echo "    You can connect to the VM with: virt-viewer $VM_NAME"
