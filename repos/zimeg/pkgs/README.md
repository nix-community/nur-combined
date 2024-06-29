# 📦 nur-packages.pkgs

Custom packages containing packaged artifacts from other repositories.

## 🔍 meta.{attributes}

Customizations to custom packages might be needed for CI caches. Some attributes
might be needed most:

- `meta.broken`: broken packages
- `meta.license.free`: unfree packages
- `preferLocalBuild`: local builds

## ❄️ result.{#flakes}

Paths to builds of local packages can be provided as parts of an expression with
impure settings:

```.envrc
use flake . --impure
```

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gon =
          if system == "x86_64-darwin" || system == "aarch64-darwin" then
            pkgs.callPackage /path/to/nur-packages/pkgs/gon/default.nix { }
          else
            null;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gon
          ];
          shellHook = "go mod tidy";
        };
      });
}
```

## 🏁 result.{#using}

Direct paths to the built source can be used in place of `zimpkgs` for faster
development:

```diff
- zimpkgs = import (builtins.fetchTarball "https://github.com/zimeg/nur-packages/archive/main.tar.gz") {};
- zimpkgs.zsh-wd
+ zsh-wd = /path/to/nur-packages/result;
```

Results can be built from changes to the source using a build command:

```sh
$ nix build .#zsh-wd
$ ls -R ./result
```
