# Nix User Repository (NUR)
# - <https://github.com/nix-community/NUR>
# this file, as viewed by NUR consumers:
# - <https://nur.nix-community.org/repos/colinsane/>
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
# - or do: `nix run '.#check-nur'` via the toplevel flake.nix in this repo
#
# if it validates here but not upstream, likely to do with different `nixpkgs` inputs.
# - CI logs: <https://github.com/nix-community/NUR/actions/workflows/update.yml>
# - run from <repo:nix-community/NUR>: `bin/nur eval colinsane`
#   - but running it this way seems to not setup the right environment
# - run from <repo:nix-community/NUR>: `./ci/update-nur.sh`
#   - after removing all but my repo from `repos.json`
#   - and afte removing excess code (e.g. the setup-git.sh call) in `ci/update-nur.sh`

{ pkgs ? import <nixpkgs> {} }:
let
  sanePkgs = builtins.removeAttrs (import ../../pkgs { inherit pkgs; }).sane [
    # XXX(2024-07-14): these packages fail NUR check, due to weird Import-From-Derivation things (bugs?).
    # see: <https://github.com/NixOS/nix/issues/9052>
    "linux-exynos5-mainline"
    "linux-megous"
    "linux-postmarketos-allwinner"
    "linux-postmarketos-exynos5"
    "linux-postmarketos-pinephonepro"
    "nixpkgs-bootstrap"
    "nixpkgs-wayland"
    "sops-nix"
    "uninsane-dot-org"
  ];
in
({
  overlays.pkgs = import ../../overlays/pkgs.nix;
  pkgs = sanePkgs;

  modules = import ../../modules { inherit (pkgs) lib; };
  lib = import ../../modules/lib { inherit (pkgs) lib; };
} // sanePkgs)
