{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  ludii = callPackage ./ludii {
    inherit rp;
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  xonsh-direnv = callPackage ./xonsh-direnv { };
}