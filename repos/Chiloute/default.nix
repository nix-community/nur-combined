{pkgs ? import <nixpkgs> {}}: {
  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
}
