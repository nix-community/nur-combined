# 🌸 fractuscontext / nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository.**

[![Build and populate cache](https://github.com/fractuscontext/nix-nur/actions/workflows/build.yml/badge.svg)](https://github.com/fractuscontext/nix-nur/actions/workflows/build.yml)

This repository hosts custom Nix packages and overlays, specifically focused on **macOS (Darwin) applications** that are either missing from or outdated in `nixpkgs`.

## 📦 What's Inside

### `overlays/mac-apps`
A custom overlay that provides auto-updated DMGs for macOS apps. These are fetched directly from upstream GitHub/GitLab releases via a custom `update-mac-apps` script.

| Package | Upstream | Architecture |
| :--- | :--- | :--- |
| **LibreWolf** | [librewolf-community](https://gitlab.com/librewolf-community/browser/bsys6) | Universal (x64/arm64) |
| **Whisky** | [Whisky-App](https://github.com/Whisky-App/Whisky) | Universal |
| **Standard Notes** | [standardnotes](https://github.com/standardnotes/app) | Universal |
| **Lunar** | [Lunar.fyi](https://github.com/alin23/Lunar) | Universal |
| **Sol** | [Sol](https://github.com/ospfranco/sol) | Universal |
| **Telegram Desktop** | [telegramdesktop](https://github.com/telegramdesktop/tdesktop) | Universal |
| **Ungoogled Chromium** | [ungoogled-software](https://github.com/ungoogled-software/ungoogled-chromium-macos) | Universal |
| **Bambu Studio** | [bambulab](https://github.com/bambulab/BambuStudio) | Universal |

## 🛠 Usage

### 1. Add to your `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # Add this repo
    my-nur.url = "github:fractuscontext/nix-nur";
  };

  outputs = { self, nixpkgs, my-nur, ... }: {
    darwinConfigurations."macbook" = darwin.lib.darwinSystem {
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ my-nur..overlays.mac-apps ];
        })
      ];
    };
  };
}
```

### 2. Install Packages

Once the overlay is added, these apps appear in your `pkgs` namespace just like standard packages:

```nix
# In your home-manager or darwin configuration
home.packages = with pkgs; [
  librewolf
  whisky
  standardnotes
];
```

## 🤖 Automation

This repo uses **GitHub Actions** to keep everything fresh:

1.  **`build.yml`**: Runs daily CI checks to ensure packages evaluate correctly and notifies the NUR registry of updates.
2.  **`overlay-update.yml`**: Runs every Tuesday to check upstream GitHub/GitLab releases. If a new version is found (e.g., a new LibreWolf DMG), it auto-generates a PR with the updated `src.json` and SHA256 hashes.

## ⚖️ License
MIT (unless otherwise noted by upstream packages).
