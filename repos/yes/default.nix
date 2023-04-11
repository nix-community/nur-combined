{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

let
  mkElectronAppImage = callPackage ./electronAppImage {
    electron = electron_22;
  };
in

{
  archlinux = recurseIntoAttrs (import ./archlinux {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./lx-music-desktop {
    inherit mkElectronAppImage rp;
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  qq-appimage = callPackage ./qq { inherit mkElectronAppImage; };

  snapgene-viewer = callPackage ./snapgene-viewer { };

  xonsh-direnv = callPackage ./xonsh-direnv { };
}