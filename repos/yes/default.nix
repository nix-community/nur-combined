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

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  xonsh-direnv = callPackage ./xonsh-direnv { };
}