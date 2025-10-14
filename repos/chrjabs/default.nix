# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> { },
  rust-overlay ? null,
}:
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # NOTE: when adding a package here, make sure to also add it in the flake overlay

  # VeriPB proof checker
  veripb = pkgs.python3Packages.callPackage ./pkgs/veripb { };

  # GBD benchmark database
  gbd = pkgs.python3Packages.callPackage ./pkgs/gbd { inherit gbdc; };
  gbdc = pkgs.python3Packages.callPackage ./pkgs/gbdc { };
  # Only the GBDC executable
  gbdc-tool = pkgs.callPackage ./pkgs/gbdc/tool.nix { };

  # Python MIP
  python-mip = pkgs.python311Packages.callPackage ./pkgs/python-mip { };

  # DBLP tools
  dblp-tools = pkgs.callPackage ./pkgs/dblp-tools { };

  # Gimsatul SAT sollver
  gimsatul = pkgs.callPackage ./pkgs/gimsatul { };

  # Coveralls reporting tool
  coveralls = pkgs.callPackage ./pkgs/coveralls { };

  # Cargo AFL fuzz helper
  cargo-afl = pkgs.callPackage ./pkgs/cargo-afl { };

  # Janus-SWI python prolog interface
  janus-swi = pkgs.python3Packages.callPackage ./pkgs/janus-swi { };

  # Clingo python API
  pyclingo = pkgs.python3Packages.callPackage ./pkgs/clingo { };
}
// pkgs.lib.attrsets.optionalAttrs (rust-overlay != null) {
  # Kani - Rust model checker
  kani = pkgs.callPackage ./pkgs/kani {
    inherit rust-overlay;
  };
}
