# 🚲 nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build and populate cache](https://github.com/zimeg/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/zimeg/nur-packages/actions/workflows/build.yml)

## 📬 nur-packages.{#using}

Contained contents can be included in other expressions using a package import.

### 🗄️ nur-packages.{#cachix}

Compiled binaries and built results can be downloaded using cache:

```sh
$ cachix use zimeg
```

### ❄️ nur-packages.{#flakes}

Custom packages can be added to flakes using custom package input:

```nix
{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zimeg.url = "github:zimeg/nur-packages";
  };
  outputs = { nixpkgs, flake-utils, zimeg, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            zimeg.packages.${pkgs.system}.etime
          ];
        };
      });
}
```

### 🏠 nur-packages.{#home-manager}

Custom paths can change packaged contents in various combinations:

```nix
{ config, pkgs, ... }:
let
  zimeg = import (builtins.fetchTarball "https://github.com/zimeg/nur-packages/archive/main.tar.gz") {};
in
{
  programs.home-manager.enable = true;
  programs.home-manager.path = "$HOME/programming/nix/home-manager";
  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "wd";
        src = zimeg.zsh-wd;
        file = "share/wd/wd.plugin.zsh";
        completions = [ "share/zsh/site-functions" ];
      }
    ];
  }
}
```
