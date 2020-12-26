{ pkgs ? import <nixpkgs> {} }:

{
  # Add modules paths
  modules = import ./modules;

  codemadness-frontends = pkgs.callPackage ./pkgs/codemadness-frontends/default.nix { };
  sfeed = pkgs.callPackage ./pkgs/sfeed/default.nix { };

  # PinePhone-related packages
  pinephone = { 
    megapixels = pkgs.callPackage ./pkgs/pinephone/megapixels/default.nix { };
    sxmo = pkgs.callPackage ./pkgs/pinephone/sxmo/default.nix { };
  };
}
