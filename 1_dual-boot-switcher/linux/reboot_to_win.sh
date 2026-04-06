#!/bin/bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script with sudo."
  exit 1
fi

GRUB_CFG_PATH="/boot/grub/grub.cfg"

log_info() { echo -e "info: $1"; }
log_success() { echo -e "successful: $1"; }
log_error() { echo -e "error $1:" >&2; }

if [[ ! -f "$GRUB_CFG_PATH" ]]; then
  log_error "grub.cfg not found by path: $GRUB_CFG_PATH"
  exit 1
fi

log_info "Searching Windows boot manager in GRUB"
WINDOWS_ENTRY=$(awk -F\' '/menuentry / && /Windows Boot Manager/ {print $2; exit}' "$GRUB_CFG_PATH")
if [[ -z "$WINDOWS_ENTRY" ]]; then
    log_error "line 'Windows Boot Manager' not found у $GRUB_CFG_PATH."
    log_error "try sudo update-grub"
    exit 1
fi
log_success "line found: $WINDOWS_ENTRY"

echo "Reboot to Windows"
if [ -z "$WINDOWS_ENTRY" ]; then
  echo "Windows boot manager not found in GRUB"
  exit 1
fi
sudo grub-reboot "$WINDOWS_ENTRY"
sudo reboot
