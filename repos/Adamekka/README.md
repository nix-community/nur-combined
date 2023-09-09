# NUR Repository - Adamekka

## Packages

- dotfile-manager

## How to install

1. Add the following lines to your `/etc/nixos/configuration.nix`

```nix
nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
```

2. Specify the packages you want to install from my repository in your `/etc/nixos/configuration.nix`

```nix
environment.systemPackages = with pkgs; [
  nur.repos.Adamekka.dotfile-manager
]
```

3. run `nixos-rebuild switch` to download, compile and install the packages

# nur-packages

![Build and populate cache](https://github.com/Adamekka/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-nltch-blue.svg)](https://nltch.cachix.org)
