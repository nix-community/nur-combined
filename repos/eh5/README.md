# EHfive's Nix flakes

## Usage

### Setup cache (optional)

```bash
$ cachix use eh5
```

or add to NixOS config

```nix
{ ... } : {
  nix.settings.substituters =  [ "https://eh5.cachix.org" ];
  nix.settings.trusted-public-keys = [ "eh5.cachix.org-1:pNWZ2OMjQ8RYKTbMsiU/AjztyyC8SwvxKOf6teMScKQ=" ];
}
```

### Build/Run package

```
$ nix run   github:EHfive/flakes#nix-gfx-mesa
$ nix build github:EHfive/flakes#packages.aarch64-linux.ubootNanopiR2s
```

### Install package, module

<details>
<summary>NixOS (flake)</summary>

```nix
# flake.nix
{
  inputs.eh5 = {
    url = "github:EHfive/flakes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, eh5 }: {
    nixosConfigurations.your-machine = nixpkgs.lib.nixosSystem rec {
      # system = ...
      modules = [
        # ...
        # imports all
        eh5.nixosModules.default
        # or on demand
        #eh5.nixosModules.mosdns
        { pkgs, ... }: {
          nixpkgs.overlays = [
            # ...
            eh5.overlays.default
          ];

          environment.systemPackages = [
            pkgs.nix-gfx-mesa # via overlay
            # or specify the package directly
            #eh5.packages.${system}.nix-gfx-mesa
          ];
        }
      ];
    };
  };
}
```

All packages in this repo are also re-exported into [github:nixos-cn/flakes](https://github.com/nixos-cn/flakes), you can install from it in same fashion as above.

```
$ nix run github:nixos-cn/flakes#re-export.einat
$ # or in full path
$ nix run github:nixos-cn/flakes#legacyPackages.x86_64-linux.re-export.einat
```

</details>
