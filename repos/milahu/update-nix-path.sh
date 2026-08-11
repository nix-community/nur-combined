#!/bin/sh

# run this after a "sudo nixos-rebuild switch"
# to update $NIX_PATH in this shell

echo "NIX_PATH before:"; echo $NIX_PATH | tr ':' $'\n' | sed 's/^/  /'

source /etc/set-environment

echo "NIX_PATH after:"; echo $NIX_PATH | tr ':' $'\n' | sed 's/^/  /'

exit 0



related:

https://discourse.nixos.org/t/where-is-nix-path-supposed-to-be-set/16434

https://discourse.nixos.org/t/how-to-change-nix-path/4864

/etc/nixos/flake.nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, ... } @ inputs: {
    nixosConfigurations.laptop1 = inputs.nixpkgs.lib.nixosSystem rec {
      modules = [
        ({ pkgs, ... }: {
          nix.nixPath = [
            "nixos=${inputs.nixpkgs}/nixos"
            "nixpkgs=${inputs.nixpkgs}"
          ];
        })
        ./configuration.nix
      ];
    };
  };
}
