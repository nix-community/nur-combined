# Antigravity Tools NixOS Flake Configuration

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![GitHub release](https://img.shields.io/github/v/release/lbjlaq/Antigravity-Manager)](https://github.com/lbjlaq/Antigravity-Manager/releases)

A NixOS package for **Antigravity Tools** — a professional game account manager and switcher. This package wraps the official Debian binary with automatic library path configuration.

**Platforms:** `x86_64-linux`

---

## Installation

Add this package to your NixOS configuration flake inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    configs.url = "github:ahmet-cetinkaya/dotfiles";
  };

  outputs = { self, nixpkgs, configs, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            configs.packages.x86_64-linux.antigravity-tools-bin
          ];
        }
      ];
    };
  };
}
```

---

## Usage

Launch the application:

```bash
antigravity_tools
```

Or find it in your application menu.

---

## Updating

An update script is provided to automatically fetch the latest release:

```bash
./update.sh
```

The script:
1. Queries the GitHub API for the latest release of [lbjlaq/Antigravity-Manager](https://github.com/lbjlaq/Antigravity-Manager)
2. Downloads the `.deb` package
3. Computes SHA256 hash
4. Updates `default.nix` with the new version and hash

---

## Runtime Dependencies

The package bundles and patches the following runtime libraries:

| Library           | Purpose                          |
|-------------------|----------------------------------|
| `gtk3`            | GTK3 GUI toolkit                 |
| `webkitgtk_4_1`   | WebKit GTK4 browser engine       |
| `libappindicator` | AppIndicator tray support        |
| `openssl`         | TLS/SSL support                  |
| `glib`            | Core GLib library                |
| `libgcc`          | GCC runtime library              |
| `libX11`          | X11 client library              |

---

## Package Structure

```text
antigravity-tools-bin/
├── default.nix       # Nix derivation (version, sources, build inputs, install phase)
├── update.sh         # Script to fetch latest release and update hashes
└── README.md
```

---

## License

The binary is licensed under **CC-BY-NC-SA-4.0** (Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International). See the [Antigravity-Manager repository](https://github.com/lbjlaq/Antigravity-Manager) for details.