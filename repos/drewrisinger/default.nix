# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Packages/updates accepted to nixpkgs/master, but need the update
  lib-scs = pkgs.callPackage ./pkgs/libraries/scs { };

  # New/unstable packages below
  libcint = pkgs.callPackage ./pkgs/libraries/libcint { };
  xcfun = pkgs.callPackage ./pkgs/libraries/xcfun { };

  python3Packages = pkgs.recurseIntoAttrs rec {
    nose-timer = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/nose-timer { };
    pyscf = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pyscf { inherit libcint xcfun; };
    pygsti = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/pygsti { inherit cvxpy nose-timer; };

    # Following are in Nixpkgs, just not made it to release yet.
    cvxpy = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cvxpy { inherit ecos osqp ; inherit (python3Packages) scs; };
    ecos = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/ecos { };
    osqp = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/osqp { };
    scs = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/scs { scs = lib-scs; };
  };

}

