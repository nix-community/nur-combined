{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs; rec {
  archlinux-keyring = callPackage ./archlinux-keyring { inherit rp; };

  asp = callPackage ./asp { inherit rp; };

  devtools = callPackage ./devtools { inherit rp; };

  pacman-gnupg = callPackage ./pacman/gnupg.nix {
    keyrings = [ archlinux-keyring ];
  };

  paru-unwrapped = callPackage ./paru/unwrapped.nix { inherit rp; };

  paru = callPackage ./paru { inherit asp devtools paru-unwrapped; };
}