{
  config,
  overlays,
  nixpkgs-bootstrap,
  stdenv,
}:
import "${nixpkgs-bootstrap.staging}/pkgs/top-level" {
  # XXX: passing through `config` here actually has observable effects: it's not *quite* idempotent.
  # see the comment above <repo:nixos/nixpkgs:pkgs/top-level/default.nix> for more details.
  # it seems to trigger rebuilds in rare circumstances.
  inherit
    config
    overlays
    ;
  localSystem = stdenv.buildPlatform.system;
  crossSystem = stdenv.hostPlatform.config;
  # XXX missing `crossOverlays = ...`; it's likely that `pkgsCross.*.pkgsStaging` does NOT compose.
}
