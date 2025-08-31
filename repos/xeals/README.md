# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

[![Gitea Action](https://git.xeal.me/xeals/nur-packages/actions/workflows/build.yml/badge.svg)](https://git.xeals.me/xeals/nur-packages/actions)
[![Cachix Cache](https://img.shields.io/badge/cachix-xeals-blue.svg)](https://xeals.cachix.org)


## Using

Using packages is easier through the combined [NUR](https://github.com/nix-community/NUR) flake.

```nix
# flake.nix
{
  inputs = {
    xeals.url = "git+https://git.xeal.me/xeals/nur-packages"; # Direct
    xeals.url = "github:xeals/nur-packages"; # GitHub mirror
  };
  
  outputs = { nixpkgs, xeals, ... }: {
    nixosConfigurations.foo = nixpkgs.lib.nixosSystem {
      modules = [
        xeals.nixosModules.betanin
      ];
    };
  };
}
```
