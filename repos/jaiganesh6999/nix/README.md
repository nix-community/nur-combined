# Nix & NixOS Packaging for SEOWebChecker

Official Nix package, Nix Flake, and NixOS module for **SEOWebChecker** ([https://seowebchecker.com/](https://seowebchecker.com/)), the comprehensive, privacy-first website SEO diagnostic and auditing engine.

---

## 🚀 Quick Start with Nix Flakes

Run an instant website audit without installing any dependencies:

```bash
# Direct run via Nix Flake
nix run github:jaiganesh6999/seowebchecker-seoaudit-sdk -- https://seowebchecker.com/

# Output in JSON or Markdown format
nix run github:jaiganesh6999/seowebchecker-seoaudit-sdk -- https://seowebchecker.com/ --format markdown
```

Install permanently into your user profile:

```bash
nix profile install github:jaiganesh6999/seowebchecker-seoaudit-sdk
```

---

## 📦 Nix User Repository (NUR)

SEOWebChecker is available on the [Nix User Repository (NUR)](https://github.com/nix-community/NUR):

```bash
# Using nix-shell with NUR
nix-shell -p nur.repos.jaiganesh6999.seowebchecker --run "seowebchecker https://seowebchecker.com/"

# Using nix-env
nix-env -f '<nixpkgs>' -iA nur.repos.jaiganesh6999.seowebchecker
```

### In `configuration.nix` with NUR

```nix
{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.nur.repos.jaiganesh6999.seowebchecker
  ];
}
```

---

## ❄️ NixOS Service Module

SEOWebChecker provides a native NixOS systemd background audit service and timer to automate continuous SEO monitoring and reports for web servers, blogs, or sites.

### 1. Import Module via Flake

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    seowebchecker = {
      url = "github:jaiganesh6999/seowebchecker-seoaudit-sdk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, seowebchecker }: {
    nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        seowebchecker.nixosModules.default
        {
          services.seowebchecker = {
            enable = true;
            urls = [
              "https://seowebchecker.com/"
              "https://example.com/"
            ];
            schedule = "daily"; # systemd OnCalendar format
            outputDir = "/var/log/seowebchecker";
            format = "json";
          };
        }
      ];
    };
  };
}
```

### 2. Import Module via Channels / Git Tarball

In `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:

let
  seowebcheckerSrc = builtins.fetchTarball "https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk/archive/main.tar.gz";
in
{
  imports = [
    "${seowebcheckerSrc}/nix/module.nix"
  ];

  services.seowebchecker = {
    enable = true;
    urls = [ "https://seowebchecker.com/" ];
    schedule = "*-*-* 03:00:00";
    outputDir = "/var/log/seowebchecker";
    format = "json";
  };
}
```

---

## 🛠️ Development & Building

Build the package locally:

```bash
# Using standard nix-build
nix-build default.nix

# Using Flakes
nix build

# Start an interactive development shell
nix develop
```

---

## 🔗 Official Links

- Website & Platform: [https://seowebchecker.com/](https://seowebchecker.com/)
- GitHub Repository: [https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk](https://github.com/jaiganesh6999/seowebchecker-seoaudit-sdk)
- License: MIT
