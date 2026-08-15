# rhencloud-nur-repo

My personal [NUR](https://github.com/nix-community/NUR) repository.

[![Build and populate cache](https://github.com/RhenCloud/rhencloud-nur-repo/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/RhenCloud/rhencloud-nur-repo/actions)
[![Cachix Cache](https://img.shields.io/badge/cachix-rhencloud-blue.svg)](https://rhencloud.cachix.org)

## Packages

| Package | Description |
| --- | --- |
| `aicommits` | A CLI that writes your git commit messages for you with AI |
| `bt-iso-enable` | Kernel module to enable Bluetooth ISO sockets via kprobe-based iso_init call |
| `cnm-player` | A command-line music player for NetEase Cloud Music |
| `herdr-plus` | Herdr plugin that adds projects and quick actions |
| `herdr-spreader` | Apply tmuxinator-style project layouts to herdr from a YAML file |
| `herdr-tab-rename` | Herdr plugin for auto-renaming tabs based on foreground directory |
| `herdr-window-title-sync` | Sync the outer terminal title to the focused Herdr workspace, tab, and agent session |
| `piri` | Extend niri compositor capabilities with extensible command system and plugins |
| `we-layerd` | A Rust daemon for running Wallpaper Engine on Linux compositors |
| `zed-globalization` | Zed Editor Chinese Localization (Zed 编辑器汉化版) |

## Overlays

- `niri` — patched niri (mouse passthrough, window pinning)
- `go-musicfox` — go-musicfox pinned to v5.1.0
- `waylyrics` — waylyrics pinned to v0.4.0

## Usage

### Flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rhencloud-nur.url = "github:RhenCloud/rhencloud-nur-repo";
  };

  outputs = { nixpkgs, rhencloud-nur, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [
            rhencloud-nur.legacyPackages.${pkgs.system}.overlays.niri
            rhencloud-nur.legacyPackages.${pkgs.system}.overlays.go-musicfox
            rhencloud-nur.legacyPackages.${pkgs.system}.overlays.waylyrics
          ];
          environment.systemPackages = [
            rhencloud-nur.packages.${pkgs.system}.aicommits
          ];
        })
      ];
    };
  };
}
```

### NUR

Once the repo is added to [NUR](https://github.com/nix-community/NUR), packages can be accessed as
`nur.repos.rhencloud.<package>` and overlays as `nur.repos.rhencloud.overlays.<name>`.
