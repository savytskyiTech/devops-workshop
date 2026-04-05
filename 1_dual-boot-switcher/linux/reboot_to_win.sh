#!/bin/bash
# replace win boot manager 
WINDOWS_ENTRY="Windows Boot Manager (on /dev/sda2)"
echo "Reboot to Windows"
sudo grub-reboot "$WINDOWS_ENTRY"
sudo reboot
