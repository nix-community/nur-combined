{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  iptux = callPackage ./iptux { };
  
  ludii = callPackage ./ludii {
    inherit rp;
  };

  mkxp-z = callPackage ./mkxp-z { };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  rgssad = callPackage ./rgssad { };

  xonsh-direnv = callPackage ./xonsh-direnv { };
}