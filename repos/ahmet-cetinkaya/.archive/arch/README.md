# 🐧 Arch Linux Install Script

This guide will walk you through the process of creating and running an Arch Linux install script to automate the installation and configuration of Arch Linux on your machine.

## ⚠️ Prerequisites

Before you run the script, ensure that:

1. **Arch Linux**
2. **BTRFS** filesystem

## ⚙️ Setup

1. **Run the Script**

    Once you're happy with the configuration, make the script executable and run it:

    ```bash
    chmod +x install.sh
    sudo ./install.sh
    ```

    This script will install yay package manager, snapper for BTRFS snapshots, sddm display manager, kde plasma desktop environment, nvidia driver and enable multilib source.

2. After the script finishes, reboot the system:

    ```bash
    reboot
    ```

## 🌟 Usage

You can use scripts in `scripts/` to install additional packages or configure your system.