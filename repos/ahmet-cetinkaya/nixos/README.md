# NixOS Configuration

A clean, modular, and flake-based NixOS configuration for my personal machines.

## 🚀 Features

- **Flake-based**: Reproducible system and home configuration.
- **Modular Structure**: Clean separation of core, desktop, and app modules.
- **Home Manager**: Declarative user-specific environment and dotfiles.
- **Plasma 6**: Modern desktop environment.
- **NVIDIA Support**: Configured for RTX 4080 Super with Wayland support.
- **Host-specific Hardware**: Hardware configuration is kept under `hosts/karakiz/`.

## 📂 Structure

```
.
├── flake.nix             # Project entry point
├── flake.lock            # Dependency versions
├── hosts/                # Host-specific configurations
│   └── karakiz/          # Main desktop (Ryzen 7 7800X3D + RTX 4080 Super)
├── modules/              # Reusable NixOS modules
│   ├── core/             # Boot, Network, Users, Locale, Printing, Sound, Plasma 6, NVIDIA
│   ├── apps/             # Development tools, AI/ML, General apps, Utilities
│   └── configs/          # Home Manager dotfile/app configs
├── home/                 # Home Manager configurations
│   └── ac/               # User 'ac' profile
└── pkgs/                 # Custom packages
```

## 🛠️ Usage

### Apply Configuration

From any working directory, apply the configuration to the current host (`karakiz`):

```bash
ac-nix-apply karakiz
```

The underlying script can also be run directly from this repository:

```bash
./scripts/apply.sh karakiz
```

### Update Dependencies

To update custom packages and flake inputs, then apply the refreshed configuration:

```bash
ac-nix-update
```

### Cleanup

To collect unused Nix store paths and optimise the store:

```bash
ac-nix-cleanup
```

### Check Configuration

To verify the configuration without building or activating it:

```bash
nix flake check --no-build
```
