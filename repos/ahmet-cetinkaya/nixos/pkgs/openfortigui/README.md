# openfortigui NixOS Flake Configuration

[![NixOS](https://img.shields.io/badge/NixOS-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![GitHub tag](https://img.shields.io/github/v/tag/theinvisible/openfortigui)](https://github.com/theinvisible/openfortigui/tags)

A NixOS package for **openfortigui** — a Qt-based GUI for `openfortivpn`, the
open-source FortiGate VPN client. This package builds from source with Qt5 and
qmake, since it is not available in nixpkgs or NUR.

**Platforms:** `linux`

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
            configs.packages.x86_64-linux.openfortigui
          ];

          # openfortigui needs passwordless sudo to start VPN tunnels.
          security.sudo.extraRules = [
            {
              groups = [ "wheel" ];
              commands = [
                {
                  command = "${configs.packages.x86_64-linux.openfortigui}/bin/openfortigui --start-vpn *";
                  options = [ "NOPASSWD" "SETENV" ];
                }
              ];
            }
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
openfortigui
```

Or find it in your application menu. Starting a VPN tunnel requires root, so the
config above grants passwordless `sudo` for the `--start-vpn` command.

---

## Updating

An update script is provided to automatically fetch the latest release:

```bash
./update.sh
```

The script:
1. Queries the GitHub **tags** API for [theinvisible/openfortigui](https://github.com/theinvisible/openfortigui/tags)
2. Computes the SRI hash via `nix flake prefetch` (includes submodules)
3. Updates `default.nix` with the new version and hash

---

## Build Dependencies

The package builds from source and links against the following libraries:

| Library                | Purpose                          |
|------------------------|----------------------------------|
| `qt5.qtbase`           | Qt5 GUI toolkit                  |
| `libsForQt5.qtkeychain`| Secure credential storage        |
| `openssl`              | TLS/SSL support                  |
| `ppp`                  | Point-to-Point Protocol daemon   |

Build tooling: `qt5.qmake`, `qt5.qttools`, `qt5.wrapQtAppsHook`.

---

## Package Structure

```text
openfortigui/
├── default.nix       # Nix derivation (version, sources, build inputs, install phase)
├── update.sh         # Script to fetch latest tag and update the hash
└── README.md
```

---

## License

openfortigui is licensed under the **GNU General Public License v3.0**. See the
[openfortigui repository](https://github.com/theinvisible/openfortigui) for
details.
