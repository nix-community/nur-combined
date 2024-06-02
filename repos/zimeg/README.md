# 🚲 nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Build and populate cache](https://github.com/zimeg/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/zimeg/nur-packages/actions/workflows/build.yml)

## 📬 nur-packages.{#using}

Contained contents can be included in other expressions using a package import.

### 🏠 nur-packages.{#home-manager}

Custom paths can change packaged contents in various combinations:

```nix
{ config, pkgs, ... }:

let
  zimpkgs = import (builtins.fetchTarball "https://github.com/zimeg/nur-packages/archive/main.tar.gz") {};
in
{
  programs.home-manager.enable = true;
  programs.home-manager.path = "$HOME/programming/nix/home-manager";
  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "wd";
        src = zimpkgs.zsh-wd;
        file = "share/wd/wd.plugin.zsh";
        completions = [ "share/zsh/site-functions" ];
      }
    ];
  }
}
```
