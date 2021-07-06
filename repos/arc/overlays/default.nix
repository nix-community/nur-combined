let
  lib = import ../lib {
    # we can get away with using some functions by passing builtins as lib
    lib = {
      foldl = builtins.foldl';
    } // builtins;
  };
  collectOverlays = builtins.foldl'
    (overlays: overlay: overlays // overlay.arc'internal or { })
    { };
  needsSanitation = pkgs: builtins.any (overlay: overlay ? arc'internal && overlay.arc'internal.path or null != ../.) pkgs.overlays;
  sanitize = pkgs: let
    sanitized = import pkgs.path {
      inherit (pkgs) config;
      overlays = builtins.filter (overlay: ! overlay ? arc'internal) pkgs.overlays;
    };
  in if overlays.hasOverlays pkgs then sanitized else pkgs;
  hasOverlay = name: pkgs: builtins.any (overlay: overlay.arc'internal.${name} or false) pkgs.overlays;
  hasOverlays = pkgs: builtins.any (overlay: overlay ? arc'internal) pkgs.overlays;

  overlays' = builtins.mapAttrs (name: overlay: {
    inherit name overlay;
    arc'internal = {
      path = ../.;
      ${name} = true;
    };

    __functor = self: self.overlay;
  }) {
    arc = import ./arc.nix;
    lib = import ./lib.nix;
    fetchurl = import ./fetchurl.nix;
    shells = import ./shells.nix;
    python = import ./python.nix;
    packages = import ./packages.nix;
    overrides = import ./overrides.nix;
  };

  overlays = overlays' // {
    ordered = [
      overlays.arc
      overlays.lib
      overlays.python
      overlays.packages
      overlays.overrides
      overlays.fetchurl
      overlays.shells
    ];

    all = {
      overlays = overlays.ordered;
      arc'internal = collectOverlays overlays.ordered // {
        path = ../.;
        inherit collectOverlays needsSanitation sanitize;
      };
      __functor = self: lib.composeManyExtensions self.overlays;
    };

    wrap = pkgs: pkgs.appendOverlays overlays.ordered;
    inherit hasOverlay hasOverlays;

    inherit (overlays.all) arc'internal;
    __functor = self: self.all;
  };
in overlays
