{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./package.nix {
  # pin to Python 3.12
  python = pkgs.python312;
  # use the latest commit on the bloodhound-ce branch:
  # https://github.com/dirkjanm/BloodHound.py/commit/ebcff847c2c3cd8c277bea7b01301920194d14f4
  pyRev = "ebcff847c2c3cd8c277bea7b01301920194d14f4";
  # first build will fail with a hash mismatch; copy the suggested sha256 here:
  pyHash = "sha256-UQZ2LY5pPliP2b9rcTi0747Fm/FurmUrcNojJdtCwxc=";
}
