{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

let
  mkElectronAppImage = callPackage ./electronAppImage {
    electron = electron_25;
  };
in

{
  ludii = callPackage ./ludii {
    inherit rp;
  };
  
  lx-music-desktop = callPackage ./lx-music-desktop {
    inherit mkElectronAppImage rp;
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  xonsh-direnv = callPackage ./xonsh-direnv { };
}