# nix-packages

## Cache

https://ccicnce113424.cachix.org

## Usage

### NUR

https://github.com/nix-community/NUR?tab=readme-ov-file#installation

### flake

Flake has package, overlay and NixOS output.

`nixosModules.modules` imports the service modules without touching
`nixpkgs.overlays`, so consumers that build their own `pkgs` should apply the
overlay there:

```nix
{
  inputs.nix-packages.url = "github:ccicnce113424/nix-packages";

  nixpkgs.overlays = [ inputs.nix-packages.overlays.default ];
  imports = [ inputs.nix-packages.nixosModules.modules ];
}
```

`nixosModules.default` is `modules` plus the overlay, for consumers that do not
manage `pkgs` themselves.
