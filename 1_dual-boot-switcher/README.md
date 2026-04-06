# Dual-Boot Switcher 
Use Case: This solves a common home lab problem where you primarily use Linux but occasionally need to quickly switch to Windows for university assignments or specific software.

# Prerequisites

To successfully use the scripts, your system must meet the following requirements:
Boot mode: UEFI (not Legacy BIOS).
Bootloader: GRUB2 (installed alongside Ubuntu).
Permissions: A user with sudo privileges in Ubuntu and Administrator rights in Windows.

# Repository Structure
```
dual-boot-switcher/
├── linux/
│   └── reboot_to_win.sh
├── windows/
│   └── reboot_to_ubuntu.bat
└── README.md
```

# From Ubuntu to Windows

The script (linux/reboot_to_win.sh) automatically finds the "Windows Boot Manager" entry in the GRUB configuration and uses the grub-reboot utility to set it as a one-time priority for the next boot. 

## Setup

You only need to allow GRUB to remember the selection once:
Open the GRUB configuration:
```
sudo nano /etc/default/grub
```

Change the GRUB_DEFAULT parameter:
```
GRUB_DEFAULT=saved
```

Apply the changes by updating GRUB:
```
sudo update-grub
```

Usage
Make the script executable and run it 
```
chmod +x ./linux/reboot_to_win.sh
```

# Part 2: From Windows to Ubuntu

soon...
