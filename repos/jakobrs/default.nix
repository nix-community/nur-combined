{ pkgs ? import <nixpkgs> {} }:

rec {
  n2n = pkgs.callPackage ./pkgs/n2n {};
  mcstatus = pkgs.python3Packages.callPackage ./pkgs/mcstatus {};

  cpptoml = pkgs.callPackage ./pkgs/cpptoml {};
  wireplumber = pkgs.callPackage ./pkgs/wireplumber { inherit cpptoml; };

  libtas = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = false; };
  libtasMulti = pkgs.libsForQt5.callPackage ./pkgs/libtas { multiArch = true; };

  libtas-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = pkgs.stdenv.hostPlatform.isx86_64; };
  libtasNoMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = false; };
  libtasMulti-unstable = pkgs.libsForQt5.callPackage ./pkgs/libtas/unstable.nix { multiArch = true; };
}
