{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  gnomeExtensions = recurseIntoAttrs (import ./gnomeExtensions {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./lx-music-desktop { inherit rp; };
}