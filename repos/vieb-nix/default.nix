{ pkgs ? import <nixpkgs> {}}: {
  vieb = pkgs.callPackage ./package.nix {};
}
