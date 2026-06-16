# Zed Preview NixOS Flake Configuration

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![GitHub release](https://img.shields.io/github/v/release/zed-industries/zed?include_prereleases)](https://github.com/zed-industries/zed/releases)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?logo=buy-me-a-coffee&logoColor=black&style=flat)](https://ahmetcetinkaya.me/donate)

A NixOS package for **Zed Editor (Preview)** — a high-performance, multiplayer code editor. This package wraps the official pre-release binary with automatic library path configuration via `autoPatchelfHook`.

**Platforms:** `x86_64-linux`, `aarch64-linux`

**Core Techs:**
[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

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
            configs.packages.x86_64-linux.zed-preview-bin
          ];
        }
      ];
    };
  };
}
```

---

## Usage

The package provides two command aliases:

- `zed` — launch the Zed editor
- `zeditor` — alternative launch command (avoids conflict with the stable `zed` package)

---

## Updating

An update script is provided to automatically fetch the latest Zed preview release:

```bash
./update.sh
```

The script:
1. Queries the GitHub API for the latest **prerelease** of [zed-industries/zed](https://github.com/zed-industries/zed)
2. Downloads tarballs for both `x86_64` and `aarch64` architectures
3. Computes SHA256 hashes for each
4. Updates `default.nix` with the new version and hashes

---

## Runtime Dependencies

The package bundles and patches the following runtime libraries:

| Library        | Purpose                          |
|----------------|----------------------------------|
| `alsa-lib`     | Audio support                    |
| `fontconfig`   | Font rendering                   |
| `glib`         | Core GLib library                |
| `glibc`        | C standard library               |
| `libxcb`       | X11 protocol library             |
| `libxkbcommon` | Keyboard handling                |
| `libX11`       | X11 client library               |
| `openssl`      | TLS/SSL support                  |
| `sqlite`       | Embedded database                |
| `vulkan-loader`| GPU acceleration                 |
| `wayland`      | Wayland display server protocol  |
| `zlib`         | Compression                      |

---

## Package Structure

```text
zed-preview-bin/
├── default.nix       # Nix derivation (version, sources, build inputs, install phase)
├── update.sh         # Script to fetch latest prerelease and update hashes
└── README.md
```

---

## License

Zed is licensed under the **GNU General Public License v3.0**, **GNU Affero General Public License v3.0**, and **Apache License 2.0** (triple-licensed). See the [Zed repository](https://github.com/zed-industries/zed) for details.
