{
  pkgs ? import <nixpkgs> { },
}:
rec {
  npupnp = pkgs.callPackage ./pkgs/npupnp { };
  libupnpp = pkgs.callPackage ./pkgs/libupnpp { inherit npupnp; };
  upplay = pkgs.callPackage ./pkgs/upplay { inherit libupnpp; };
  eezupnp = pkgs.callPackage ./pkgs/eezupnp { };
  betterbird-bin = pkgs.callPackage ./pkgs/betterbird-bin { };
  czkawka-git = pkgs.callPackage ./pkgs/czkawka-git { };
  birt-designer = pkgs.callPackage ./pkgs/birt-designer { jdk = pkgs.jdk21; };
  beurer_bf100_parser = pkgs.callPackage ./pkgs/beurer_bf100_parser { };
}
