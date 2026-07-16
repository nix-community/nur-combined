# Nix User Repository (NUR)
# - <https://github.com/nix-community/NUR>
# this file, as viewed by NUR consumers:
# - <https://nur.nix-community.org/repos/colinsane/>
#
# this file is not reachable from the top-level of my nixos configs (i.e. toplevel default.nix)
# nor is it intended for anyone who wants to reference my config directly
#   (consider the toplevels: /default.nix, /pkgs/default.nix, /overlays/*.nix, or /modules/default.nix instead).
#
# rather, this is the entrypoint through which NUR finds my packages, modules, overlays.
# it's reachable only from those using this repo via NUR.
#
# to manually query available packages, modules, etc:
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
#   - and after removing excess code (e.g. the setup-git.sh call) in `ci/update-nur.sh`
# - from this repo, import the NUR with `repoOverrides.colinsane` pointed back here
#   - see: <https://nur.nix-community.org/documentation/#overriding-repositories>

{ pkgs ? import <nixpkgs> {} }:
let
  sane = import ../../pkgs/packages.nix pkgs;
  sane' = removeAttrs sane [
    # XXX(2024-07-14): these packages fail NUR check, due to weird Import-From-Derivation things (bugs?).
    # see: <https://github.com/NixOS/nix/issues/9052>
    "linux-exynos5-mainline"
    "linux-postmarketos-allwinner"
    "linux-postmarketos-exynos5"
    "linux-postmarketos-pinephonepro"
    "linux-postmarketos-qcom-sdm845"
    # TODO(2026-05-18): mpvScripts.sane_cast takes sane-cast as callarg; that doesn't exist when packages are placed in a `sane` scope!
    "mpvScripts"
    "pkgsSpliced"  #< error: path ... did not exist in the store during evaluation
    "sane-nix-files"
    # these use IFD by design
    "nixpkgs-bootstrap"
    "nixpkgs-wayland"
    "nur" # redundant
    "sops-nix"
    "uninsane-dot-org"
  ];
in
  # NUR expects the following schema, as per <https://nur.nix-community.org/documentation/#nixos-modules-overlays-and-library-function-support>:
  # - toplevel is a package set
  # - optionally: `lib` is an arbitrary collection of nix expressions (similar to nixpkgs' lib)
  # - optionally: `modules` is an attrset from String -> Path
  # - optionally: `overlays` is an attrset from String -> (Attrs -> Attrs)
  sane' // {
    # too lazy to expose overlays/modules individually right now; let me know if you want that.
    overlays = {
      all = import ../../overlays/all.nix;
      pkgs = import ../../overlays/pkgs.nix;
    };
    modules.all = ../../modules;
  }
