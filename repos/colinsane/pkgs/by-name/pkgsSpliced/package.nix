# returns a package set containing `__splicedPackages`, within which each package has a __spliced attrset.
# the toplevel `callPackage` also becomes splicing-aware.
# e.g. `pkgsSpliced.callPackage ({ hello }: hello.__spliced) {}` yields `{ buildBuild = ...; buildHost = ...; ... }`.
#
# the constructed package set is re-entrant, so e.g. `pkgsSpliced.pkgsMusl` packages also get the `__spliced` attribute, built from the musl packages set.
#
# under the hood it's magic and likely prone to breakage, but there's *very few options for doing this correctly*.
#
# pkgs/top-level/stage.nix imports pkgs/top-level/splice.nix
# - `actuallySplice` is set based on if the stdenv requested it.
#   if not, **you're toast**. trial and error shows no way to reliably perform the stage.nix logic after the `pkgs` set has been constructed.
#   the stdenv requests splicing by setting `selfBuild = false` for a given stage.
#   pkgs/stdenv/cross/default.nix is the only one to do this.
#
# the `crossOverlays` nixpkgs parameter is used to activate pkgs/stdenv/cross/default.nix.
# unlike `overlays` though, it's destructive -- we have no (easy) way to query the present `crossOverlays`.
# thereforce, make the whole thing be a no-op if there's already `crossOverlays` present.
# we would already have splicing configured in such a case anyway.
# detect this by querying `recurseForDerivations`: `pkgs/top-level/splice.nix` sets it `false` when splicing is activate.
{
  config,
  overlays,
  path,
  pkgs,
  recurseForDerivations ? true,
  stdenv,
}:
if recurseForDerivations then
  import "${path}/pkgs/top-level" {
    # XXX: passing through `config` here actually has observable effects: it's not *quite* idempotent.
    # see the comment above <repo:nixos/nixpkgs:pkgs/top-level/default.nix> for more details.
    # it seems to trigger rebuilds in rare circumstances.
    inherit
      config
      overlays
      ;
    localSystem = stdenv.buildPlatform.system;
    crossSystem = stdenv.hostPlatform.config;
    crossOverlays = [(_self: _super: {})];
  }
else
  pkgs
