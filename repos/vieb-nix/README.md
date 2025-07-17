Nix packaging for [Vieb](https://github.com/Jelmerro/Vieb).

It is provided here since Vieb was rejected from nixpkgs due to security concerns about an electron based browser, and special rules in nixpkgs policy regarding browsers.

# Installation

## Flake

In addition to the normal `packages` output, this flake provides the non-standard `packagesFunc`, which is a function taking a `pkgs` value and returning an attrset of packages (in this case, just `vieb`).

This allows you to easily use vieb without re-instantiating nixpkgs.

An example for a nixos configuration flake:

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.vieb-nix.url = "github:tejing1/vieb-nix";
  inputs.vieb-nix.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { nixpkgs, vieb-nix, ...}: {
    hostname = nixpkgs.lib.nixosSystem {
      system = "x86-64-linux";
      modules = [
        ./configuration.nix
        ({pkgs, ...}: {
          environment.systemPackages = [ (vieb-nix.packagesFunc pkgs).vieb ];
        })
      ];
    };
  }
}
```

In practice, you'll likely prefer to carry the flake inputs through to your configuration.nix and set the same setting there. There are other guides about how to do this if you don't already know.

## Non-Flake

This repo's `default.nix` accepts a named argument `pkgs` and returns an attrset containing the `vieb` attribute.

```nix
{ pkgs, ... }:
let
  # This is not reproducible! Consider pinning methods.
  vieb-nix = import (
    builtins.fetchTree {
      type = "github";
      owner = "tejing1";
      repo = "nixos-config";
    }
  ) { inherit pkgs; };
in {
  environment.systemPackages = [ vieb-nix.vieb ];
}
```

## NUR

If you use the [Nix User Repository](https://github.com/nix-community/NUR), then Vieb is available under `repos.vieb-nix.vieb`.
