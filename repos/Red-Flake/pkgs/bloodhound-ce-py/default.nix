{
  pkgs ? import <nixpkgs> { },
  python ? pkgs.python312, # Make python parameterizable
}:
pkgs.callPackage ./package.nix {
  # use the passed python parameter instead of hardcoded pkgs.python312
  python = python;
  # use the latest commit on the bloodhound-ce branch:
  # https://github.com/dirkjanm/BloodHound.py/commit/ebcff847c2c3cd8c277bea7b01301920194d14f4
  pyRev = "ebcff847c2c3cd8c277bea7b01301920194d14f4";
  # first build will fail with a hash mismatch; copy the suggested sha256 here:
  pyHash = "sha256-UQZ2LY5pPliP2b9rcTi0747Fm/FurmUrcNojJdtCwxc=";
}
