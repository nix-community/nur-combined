# My personal nix-repository
[![Build Status](https://travis-ci.org/kampka/nix-packages.svg?branch=master)](https://travis-ci.org/kampka/nix-packages)

This repository contains nix expressions, including derivations of packages that I maintain, mostly for myself.

## Usage

#### Nix User Repository

This repository is available via the [Nix User Repository](https://github.com/nix-community/NUR)

Packages can be installed from the NUR via the `kampka` namespace, eg:
```console
$ nix-env -iA nur.repos.kampka.nixify
```
This is the preferred way of installing packages from this repository.

#### Without the NUR

To make the repository accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:
```nix
{
  packageOverrides = pkgs: {
    kampka = pkgs.callPackage (import (builtins.fetchGit {
      url = "https://github.com/kampka/nix-packages";
    })) {};
  };
}
```

For NixOS add the following to your `/etc/nixos/configuration.nix`:
```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    kampka = pkgs.callPackage (import (builtins.fetchGit {
       url = "https://github.com/kampka/nix-packages";
    })) {};
  };
}
```

Then packages can be used or installed from the `kampka` namespace.
```console
$ nix-shell -p kampka.nixify
```
or
```console
$ nix-env -iA kampka.nixify
```
or
```nix
{
    # /etc/nixos/configuration.nix
    environment.systemPackages = [
      kampka.nixify
    ];
}
```

#### Modules

Modules defined in this repository are defined in the `kampka` namespace.
This helps to avoid namespace conflicts with the `nixpkgs` and other `NUR` repositories.

To enable these modules, you simply define the path accordingly:
```nix
{ pkgs, config, lib, ... }:
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in {

  imports = [
    nur-no-pkgs.repos.kampka.modules.zsh-history
  ];

  kampka.programs.zsh-history.enable = true;

}
```
