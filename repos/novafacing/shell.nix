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
      angr-pkgs.python37Packages.angr
    ];
    python37WithAngr = python37.withPackages packages;

  in stdenv.mkDerivation rec {
    name = "angr";
    buildInputs = [ python37WithAngr ];
  }
