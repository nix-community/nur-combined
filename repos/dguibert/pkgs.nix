{ versions ? import ./versions.nix
, nixpkgs ? { outPath = versions.nixpkgs; revCount = 123456; shortRev = "gfedcba"; }
, # The system packages will be built on. See the manual for the
  # subtle division of labor between these two `*System`s and the three
  # `*Platform`s.
  localSystem ? { system = builtins.currentSystem; }

, # These are needed only because nix's `--arg` command-line logic doesn't work
  # with unnamed parameters allowed by ...
  system ? localSystem.system
, platform ? localSystem.platform
, # The system packages will ultimately be run on.
  crossSystem ? localSystem

, # Allow a configuration attribute set to be passed in as an argument.
  config ? import ./config.nix

, # List of overlays layers used to extend Nixpkgs.
  overlays ? []

, # List of overlays to apply to target packages only.
  crossOverlays ? []

, # A function booting the final package set for a specific standard
  # environment. See below for the arguments given to that function, the type of
  # list it returns.
  stdenvStages ? null #import ../stdenv
} @ args:

let
  otherPackageSets = self: super: {
    # Extend the package set with zero or more overlays. This preserves
    # preexisting overlays. Prefer to initialize with the right overlays
    # in one go when calling Nixpkgs, for performance and simplicity.
    appendOverlays = extraOverlays:
      if extraOverlays == []
      then self
      else import ./pkgs.nix (
        args // {
          overlays = (args.overlays or []) ++ extraOverlays;
        });

    # Extend the package set with a single overlay. This preserves
    # preexisting overlays. Prefer to initialize with the right overlays
    # in one go when calling Nixpkgs, for performance and simplicity.
    # Prefer appendOverlays if used repeatedly.
    extend = f: self.appendOverlays [f];
  };

  glibc_2_26 = self: super: {
    glibc = super.callPackage ./pkgs/glibc/2.26 { };
  };

  pkgs = import nixpkgs (
    (builtins.removeAttrs args ["versions" "nixpkgs" ]) // {
      overlays =  [ otherPackageSets ] ++ (args.overlays or []);
    });

in pkgs
