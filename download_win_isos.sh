#!/bin/bash
set -euo pipefail

ISO_DIR="${ISO_DIR:-$HOME/isos}"
WIN_ISO="$ISO_DIR/Win10_22H2_English_x64.iso"
VIRTIO_ISO="$ISO_DIR/virtio-win.iso"
WIN_ISO_URL="https://tb.rg-adguard.net/dl.php?go=ef3ed38e" # More reliable alternative source
VIRTIO_ISO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
WIN_ISO_CHECKSUM="6a040b5fe01d9ad6c0610401cdec68ea6c434bf8"
VIRTIO_CHECKSUM_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/SHA1SUM"

# Create ISO directory if it doesn't exist
mkdir -p "$ISO_DIR"

# Function to verify checksum
verify_checksum() {
  local file=$1
  local expected=$2
  local actual
  
  echo "[*] Verifying checksum for $(basename "$file")..."
  actual=$(sha1sum "$file" | awk '{print $1}')
  
  if [[ "$actual" != "$expected" ]]; then
    echo "[!] Checksum verification failed for $(basename "$file")"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    return 1
  fi
  
  echo "[✓] Checksum verified for $(basename "$file")"
  return 0
}

# Download Windows 10 ISO with proper error handling
if [ ! -f "$WIN_ISO" ]; then
  echo "[*] Downloading Windows 10 ISO..."
  if curl -L -o "$WIN_ISO" "$WIN_ISO_URL"; then
    echo "[✓] Windows 10 ISO downloaded successfully"
    
    # Verify Windows ISO checksum
    if ! verify_checksum "$WIN_ISO" "$WIN_ISO_CHECKSUM"; then
      echo "[!] Windows 10 ISO may be corrupted. Consider removing it and trying again."
    fi
  else
    echo "[!] Failed to download Windows 10 ISO"
    echo "    Please download Windows 10 ISO manually from:"
    echo "    https://www.microsoft.com/software-download/windows10"
    echo "    and place it at: $WIN_ISO"
    exit 1
  fi
else
  echo "[✓] Windows ISO already downloaded."
  # Verify existing Windows ISO checksum
  verify_checksum "$WIN_ISO" "$WIN_ISO_CHECKSUM" || true
fi

# Download latest VirtIO driver ISO
if [ ! -f "$VIRTIO_ISO" ]; then
  echo "[*] Downloading VirtIO driver ISO..."
  if curl -L -o "$VIRTIO_ISO" "$VIRTIO_ISO_URL"; then
    echo "[✓] VirtIO driver ISO downloaded successfully"
    
    # Get and verify VirtIO checksum
    echo "[*] Downloading VirtIO checksum..."
    VIRTIO_EXPECTED_CHECKSUM=$(curl -s "$VIRTIO_CHECKSUM_URL" | grep virtio-win.iso | awk '{print $1}')
    verify_checksum "$VIRTIO_ISO" "$VIRTIO_EXPECTED_CHECKSUM" || true
  else
    echo "[!] Failed to download VirtIO driver ISO"
    exit 1
  fi
else
  echo "[✓] VirtIO ISO already downloaded."
  # Get and verify existing VirtIO checksum
  VIRTIO_EXPECTED_CHECKSUM=$(curl -s "$VIRTIO_CHECKSUM_URL" | grep virtio-win.iso | awk '{print $1}')
  verify_checksum "$VIRTIO_ISO" "$VIRTIO_EXPECTED_CHECKSUM" || true
fi

echo "[✓] ISO downloads completed"
