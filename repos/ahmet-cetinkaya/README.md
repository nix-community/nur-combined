<div align="center">

# `dotfiles`

[![GitHub stars](https://img.shields.io/github/stars/ahmet-cetinkaya/dotfiles?style=flat&logo=github)](https://github.com/ahmet-cetinkaya/dotfiles/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/ahmet-cetinkaya/dotfiles?style=flat&logo=git&logoColor=white)](https://github.com/ahmet-cetinkaya/dotfiles/commits/main)
[![GitHub license](https://img.shields.io/github/license/ahmet-cetinkaya/dotfiles?style=flat)](https://github.com/ahmet-cetinkaya/dotfiles/blob/main/LICENSE)

Personal configuration files for my Linux and Windows machines — managed declaratively with NixOS and synced across desktops.

![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=flat&logo=nixos&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=flat&logo=archlinux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=hyprland&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat&logo=windows&logoColor=white)

</div>

## ✨ Highlights

- **Declarative NixOS**: Flake-based, modular system configuration with custom packages and Home Manager.
- **Multi-OS**: Configs for NixOS, Arch Linux, and Windows (Atlas OS) living side by side.
- **Wayland-first**: Hyprland compositor with Quickshell, Waybar, SwayNC, and Rofi.
- **Consistent shell**: Zsh + Starship/Oh My Posh prompt, with Fastfetch and shared aliases.
- **Editors ready**: Neovim, VSCodium, Zed, and Visual Studio settings.

## 📂 Structure

```text
.
├── nixos/            # Flake-based NixOS configuration (see nixos/README.md)
├── arch/             # Arch Linux install script & package lists (see arch/README.md)
├── atlas-os/         # Windows (Atlas OS) tweaks
│
├── hyprland/         # Wayland compositor config
├── quickshell/       # Quickshell (Noctalia) desktop shell
├── waybar/           # Status bar
├── swaync/           # Notification center
├── rofi/             # Application launcher
├── eww/              # Widgets
├── albert/           # Launcher (X11)
│
├── kitty/            # Terminal emulator
├── zsh/              # Shell + plugins (submodules)
├── starship/         # Prompt
├── oh-my-posh/       # Prompt (Windows/PowerShell)
├── fastfetch/        # System info
│
├── neovim/           # Neovim config
├── vs-codium/        # VSCodium settings
├── zed/              # Zed editor settings
├── visual-studio/    # Visual Studio settings
│
├── firefox/          # Browser config
├── vesktop/          # Discord client settings
├── konsave/          # KDE config snapshots
│
├── windows-terminal/ # Windows Terminal settings
├── powershell/       # PowerShell profile
├── zebar/            # Windows status bar
├── glaze-vm/         # GlazeWM tiling window manager
│
├── scripts/          # Shared helper scripts (format, lint)
└── prettier/         # Formatting config
```

## 🚀 Getting Started

Clone the repository with its submodules:

```bash
git clone --recurse-submodules https://github.com/ahmet-cetinkaya/dotfiles.git ~/Configs
cd ~/Configs
```

> [!TIP]
> If you already cloned without `--recurse-submodules`, run
> `git submodule update --init --recursive` to fetch the Zsh plugins and Quickshell themes.

### 🐧 NixOS

The NixOS configuration is fully declarative. To apply it on the main host (`karakiz`):

```bash
sudo nixos-rebuild switch --flake ./nixos#karakiz
```

See [nixos/README.md](nixos/README.md) for details on structure, custom packages, and updating inputs.

### 🏗️ Arch Linux

```bash
cd arch
chmod +x install.sh && sudo ./install.sh
```

See [arch/README.md](arch/README.md) for prerequisites and post-install scripts.

### 🪟 Windows

Windows-specific configs (Windows Terminal, PowerShell, Zebar, Glaze VM, Atlas OS) are copied manually to their respective locations.

## 🛠️ Maintenance

Shared helper scripts live in `scripts/`:

```bash
./scripts/format.sh    # Format config files
./scripts/lint.sh      # Lint config files
```

Agent and contribution guidelines are documented in [AGENTS.md](AGENTS.md).

## 🤝 Contributing

These are personal dotfiles, but feel free to open an issue or borrow anything useful. Suggestions and fixes are always welcome.

## 📄 License

Released under the [MIT License](LICENSE) unless a subdirectory states otherwise.
