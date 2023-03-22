{ self, inputs, ... }:
let
  inherit (inputs) nixpkgs;

  lib = nixpkgs.lib.extend (final: _: {
    my = import "${self}/lib" { inherit inputs; pkgs = nixpkgs; lib = final; };
  });
in
{
  flake.lib = lib;
}
