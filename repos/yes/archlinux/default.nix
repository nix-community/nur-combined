{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs; rec {
  archlinux-keyring = callPackage ./archlinux-keyring { inherit rp; };
  pacman = callPackage ./pacman { inherit rp; };
  pacman-gnupg = callPackage ./pacman/gnupg.nix {
    inherit pacman;
    keyrings = [ archlinux-keyring ];
  };
  arch-install-scripts = callPackage ./arch-install-scripts {
    inherit rp pacman; 
  };
  devtools = callPackage ./devtools {
    inherit rp pacman arch-install-scripts;
  };
}