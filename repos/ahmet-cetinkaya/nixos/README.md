# NixOS Configuration

A clean, modular, and flake-based NixOS configuration for my personal machines.

## 🚀 Features

- **Flake-based**: Reproducible system and home configuration.
- **Modular Structure**: Clean separation of core, desktop, and app modules.
- **Home Manager**: Declarative user-specific environment and dotfiles.
- **Plasma 6**: Modern desktop environment.
- **NVIDIA Support**: Configured for RTX 4080 Super with Wayland support.
- **Unified Hardware Sync**: Fully synced with `/etc/nixos` for real hardware compatibility.

## 📂 Structure

```
.
├── flake.nix             # Project entry point
├── flake.lock            # Dependency versions
├── hosts/                # Host-specific configurations
│   └── karakiz/          # Main desktop (Ryzen 7 7800X3D + RTX 4080 Super)
├── modules/              # Reusable NixOS modules
│   ├── core/             # Boot, Network, Users, Locale, Printing, Sound
│   ├── desktop/          # Plasma 6, NVIDIA Drivers
│   └── apps/             # Development tools, General apps
├── home/                 # Home Manager configurations
│   └── ac/               # User 'ac' profile
└── pkgs/                 # Custom packages
```

## 🛠️ Usage

### Apply Configuration

To apply the configuration to the current host (`karakiz`):

```bash
sudo nixos-rebuild switch --flake .#karakiz
```

### Update Dependencies

To update the flake inputs:

```bash
nix flake update
```

### Check Syntax

To verify the configuration without building:

```bash
nix flake check
```
