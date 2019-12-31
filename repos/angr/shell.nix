{ ANGR_NIXPKGS_PATH
}:

with import <nixpkgs> { };

let
  angr-pkgs = import ANGR_NIXPKGS_PATH { inherit pkgs; };
in
  let
    # Dependencies are propagated, so most of other "angr-related" packages will be available.
    # See `pkgs/python-modules/angr/default.nix` .
    packages = ps: with ps; [
      angr-pkgs.python3Packages.angr
    ];
    python3WithAngr = python3.withPackages packages;

  in stdenv.mkDerivation rec {
    name = "angr";
    buildInputs = [ python3WithAngr ];
  }
