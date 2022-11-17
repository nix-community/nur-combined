{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs; rec {
  archlinux-keyring = callPackage ./archlinux-keyring { inherit rp; };

  asp = callPackage ./asp { inherit rp; };

  devtools = callPackage ./devtools { inherit rp; };

  paru-unwrapped = callPackage ./paru/unwrapped.nix {};

  paru = callPackage ./paru { inherit asp devtools paru-unwrapped; };

  run-archiso = callPackage ./archiso/run.nix { inherit rp; };
}