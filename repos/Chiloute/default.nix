{pkgs ? import <nixpkgs> {}}: {
  modules = import ./modules;

  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
  vpn-tui = pkgs.callPackage ./pkgs/vpn-tui {};
}
