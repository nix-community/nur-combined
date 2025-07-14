# 🧃 My NUR Repository

This is my personal [NUR (Nix User Repository)](https://github.com/nix-community/NUR), created for:

- Storing software I use daily;
- Providing more up-to-date versions of packages than those available in `nixpkgs`;
- Offering automatic daily updates to ensure all software stays up to date.

---

## 🛠 Usage (via the official NUR repository)

If you have enabled the [official NUR repository](https://github.com/nix-community/NUR), you can access packages from this repo via `nur.legacyPackages."${system}".repos.lonerOrz`.

### Flake Example

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur }: {
    nixosConfigurations.myConfig = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # Adds the NUR overlay
        nur.modules.nixos.default
        # NUR modules to import
        nur.legacyPackages."${system}".repos.iopq.modules.xraya
        # This adds the NUR nixpkgs overlay.
        # Example:
        # ({ pkgs, ... }: {
        #   environment.systemPackages = [ pkgs.nur.repos.mic92.hello-nur ];
        # })
      ];
    };
  };
}
```

If you haven’t enabled NUR yet, please refer to the setup guide:
[https://github.com/nix-community/NUR#using-the-repository](https://github.com/nix-community/NUR#using-the-repository)

---

## 🔄 Auto-Update Mechanism

This repository is automatically updated on a daily basis using GitHub Actions:

- Fetches the latest source code of packages every day;
- Automatically builds and pushes results to the [Cachix](https://loneros.cachix.org) cache;
- Build status is publicly visible for easy debugging.

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

![Build and populate cache](https://github.com/lonerOrz/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-loneros-blue.svg)](https://loneros.cachix.org)
