# if an expression `nix-build -A ATTRPATH` fails:
# > error: Refusing to evaluate package ... because it has problems:
# > - broken: This package is broken.
#
# then, either:
# - `nix-build -A pkgsBroken.ATTRPATH`
# - or: `NIXPKGS_ALLOW_BROKEN=1 nix-build -A ATTRPATH`
{
  config,
  overlays,
  stdenv,
  path,
}:
import "${path}/pkgs/top-level" {
  # XXX: passing through `config` here actually has observable effects: it's not *quite* idempotent.
  # see the comment above <repo:nixos/nixpkgs:pkgs/top-level/default.nix> for more details.
  # it seems to trigger rebuilds in rare circumstances.
  inherit overlays;
  config = config // {
    allowBroken = true;
  };
  localSystem = stdenv.buildPlatform.system;
  crossSystem = stdenv.hostPlatform.config;
  # XXX missing `crossOverlays = ...`; it's likely that `pkgsCross.*.pkgsBroken` does NOT compose.
}
