{pkgs ? import <nixpkgs> {}}: {
  modules = import ./modules {vpnTuiSrc = (pkgs.callPackage ./pkgs/vpn-tui {}).src;};

  jwt-tui = pkgs.callPackage ./pkgs/jwt-tui {};
  vpn-tui = pkgs.callPackage ./pkgs/vpn-tui {};
}
