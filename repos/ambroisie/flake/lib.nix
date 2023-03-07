{ self, nixpkgs, ... } @ inputs:
let
  lib = nixpkgs.lib.extend (final: _: {
    my = import "${self}/lib" { inherit inputs; pkgs = nixpkgs; lib = final; };
  });
in
lib
