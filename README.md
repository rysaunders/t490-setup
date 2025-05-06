# ThinkPad T490 Setup

This repository provides scripts to automate the setup of a ThinkPad T490 running Ubuntu. It includes:

- System configuration with Ansible
- Dotfiles installation
- Windows VM setup (optional)

## Quick Start

```bash
# Clone this repository
git clone https://github.com/rysaunders/t490-setup
cd t490-setup

# Run the bootstrap script
./bootstrap.sh
```

## What Does It Do?

1. Updates the system and installs necessary packages
2. Downloads Windows 10 ISO and VirtIO drivers (for VM)
3. Sets up a Windows virtual machine (optional)
4. Configures the system using Ansible:
   - Installs common software (editors, containers, etc.)
   - Sets up the desktop environment (i3, polybar, etc.)
   - Configures user shell and environment
   - Sets up virtualization tools
5. Installs dotfiles from the included dotfiles directory

## Customization

Copy the sample configuration:

```bash
cp config.sample.conf ~/.t490-setup.conf
nano ~/.t490-setup.conf
```

Edit the values to match your preferences. The configuration allows you to:

- Change username and dotfiles repository
- Configure VM settings (RAM, CPUs, disk size)
- Add additional packages to install
- Skip components (Windows ISO download, VM creation, dotfiles)

## Components

### bootstrap.sh

The main entry point that coordinates the setup process.

### setup.yml

Ansible playbook for system configuration.

### download_win_isos.sh

Downloads Windows 10 ISO and VirtIO drivers.

### create_win_vm.sh

Creates a Windows 10 virtual machine.

### dotfiles/install.sh

Installs your personal dotfiles.

## Requirements

- Ubuntu 20.04 or newer
- Internet connection
- Sudo privileges

## Troubleshooting

### Windows VM Issues

- If VM creation fails, check if the virtualization packages are installed:
  ```bash
  sudo apt install qemu-kvm libvirt-daemon-system virt-manager
  ```

- Ensure your user is in the correct groups:
  ```bash
  sudo usermod -aG libvirt,kvm $(whoami)
  ```

### Dotfiles Installation

- If dotfiles installation fails, check that your dotfiles repository exists and contains an `install.sh` script.

## License

MIT