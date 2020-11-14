{ pkgs ? import <nixpkgs> {} }:

rec {
  n2n = pkgs.callPackage ./pkgs/n2n {};
  mcstatus = pkgs.python3Packages.callPackage ./pkgs/mcstatus {};

  cpptoml = pkgs.callPackage ./pkgs/cpptoml {};
  wireplumber = pkgs.callPackage ./pkgs/wireplumber { inherit cpptoml; };
}
