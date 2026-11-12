{pkgs ? import <nixpkgs> {}}: {
  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
  vpn-tui = pkgs.callPackage ./pkgs/vpn-tui {};
}
