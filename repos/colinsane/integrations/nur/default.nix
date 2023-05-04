# Nix User Repository (NUR)
# - <https://github.com/nix-community/NUR>
#
# this file is not reachable from the top-level of my nixos configs (i.e. toplevel flake.nix)
# nor is it intended for anyone who wants to reference my config directly
#   (consider the toplevel flake.nix outputs instead).
#
# rather, this is the entrypoint through which NUR finds my packages, modules, overlays.
# it's reachable only from those using this repo via NUR.
#
# to manually query available packages, modules, etc, try:
# - nix eval --impure --expr 'builtins.attrNames (import ./. {})'
#
# to validate this before a push that would propagate to NUR:
#   NIX_PATH= NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix-env -f . -qa \* --meta --xml \
#     --allowed-uris https://static.rust-lang.org \
#     --option restrict-eval true \
#     --option allow-import-from-derivation true \
#     --drv-path --show-trace \
#     -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
#     -I ../../
# ^ source: <https://github.com/nix-community/nur-packages-template/blob/master/.github/workflows/build.yml#L63>
#   N.B.: nur eval allows only PATH (inherited) and NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM="1" (forced),
#   hence the erasing of NIX_PATH above (to remove external overlays)

{ pkgs ? import <nixpkgs> {} }:
let
  sanePkgs = import ../../pkgs { inherit pkgs; };
in
({
  overlays.pkgs = import ../../overlays/pkgs.nix;
  pkgs = sanePkgs;

  modules = import ../../modules { inherit (pkgs) lib; };
  lib = import ../../modules/lib { inherit (pkgs) lib; };
} // sanePkgs)
