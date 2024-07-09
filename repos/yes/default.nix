{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  ludii = callPackage ./ludii {
    inherit rp;
  };

  mkxp-z = callPackage ./mkxp-z { };

  rgssad = callPackage ./rgssad { };

  xonsh-direnv = callPackage ./xonsh-direnv { };
}