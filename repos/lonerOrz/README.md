# 🧃 My NUR Repository

**NUR Sync Status:** [![NUR Sync Status](https://github.com/lonerOrz/loneros-nur/actions/workflows/nur-sync.yml/badge.svg)](https://github.com/lonerOrz/loneros-nur/actions/workflows/nur-sync.yml)

![NUR Sync Status Chart](https://raw.githubusercontent.com/lonerOrz/loneros-nur/nur-sync-status/status.svg)

---

This is my personal [NUR (Nix User Repository)](https://github.com/nix-community/NUR), created for:

- Storing software I use daily;
- Providing more up-to-date versions of packages than those available in `nixpkgs`;
- Offering automatic daily updates to ensure all software stays up to date.

---

## 📦 Packages

This repository contains subjective package selections that I personally use. These include:

- Communication software (QQ, WeChat, etc.)
- Development tools (Qwen-code, etc.)
- Multimedia applications (MPV Handler, Linux Wallpaper Engine, etc.)
- Various utilities and other applications

For a complete list of available packages, please browse the [pkgs/](./pkgs) directory.

---

## 🛠 Usage (via the official NUR repository)

If you have enabled the [official NUR repository](https://github.com/nix-community/NUR), you can access packages from this repo via `nur.repos.lonerOrz`.

### Flake Example

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, nur }: {
    # Use packages directly
    packages.x86_64-linux.qq = nur.repos.lonerOrz.qq;
    packages.x86_64-linux.wechat = nur.repos.lonerOrz.wechat;

    # Or in a NixOS configuration
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = with nur.repos.lonerOrz; [
            qq
            wechat
            mpv-handler
          ];
        })
      ];
    };
  };
}
```

If you haven't enabled NUR yet, please refer to the setup guide:
[https://github.com/nix-community/NUR#using-the-repository](https://github.com/nix-community/NUR#using-the-repository)

---

## 🔄 Auto-Update Mechanism

This repository is automatically updated on a daily basis using GitHub Actions:

- Fetches the latest source code of packages every day;
- Automatically builds and pushes results to the [Cachix](https://loneros.cachix.org) cache;
- Build status is publicly visible for easy debugging.

The update process is handled by custom update scripts for each package, which can fetch the latest versions from various sources including:

- NPM registries
- GitHub releases
- Official download pages
- CDN sources

---

## 🙌 Contributing

If you also need the latest versions of certain software, you're welcome to contribute:

- **Submit a PR**: Add your package to this repo; CI will take care of automatic updates;
- **Open an issue**: Request to add or update software;
- **Suggest improvements**: Propose ideas to improve the build/update workflow or caching setup.

The goal is to maintain a useful, reliable, and up-to-date NUR repository for both myself and others.

---

## 📄 License

Each package in this repository follows its original license.
The build logic and repository scripts are released under the [MIT License](./LICENSE).

---

## ☁️ Cache & Build Status

**My personal Cachix Cache**

- substituter: `https://loneros.cachix.org`
- public-key: `loneros.cachix.org-1:dVCECfW25sOY3PBHGBUwmQYrhRRK2+p37fVtycnedDU=`

[![Cachix Cache](https://img.shields.io/badge/cachix-loneros-blue.svg)](https://loneros.cachix.org)
