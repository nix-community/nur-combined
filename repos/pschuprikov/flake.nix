{
  description = "NUR flake";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      lib = pkgs.lib;
      nur = import self { pkgs = pkgs; };
    in {
      packages.x86_64-linux =
        lib.filterAttrs (n: d: lib.isDerivation d && !(d.meta.broken or false))
        nur;
      inherit (nur) overlays;
    };
}
