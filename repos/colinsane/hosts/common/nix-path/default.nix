{ pkgs, sane-lib, ... }:

{
  # allow `nix-shell` (and probably nix-index?) to locate our patched and custom packages
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    # note the import starts at repo root: this allows `./overlay/default.nix` to access the stuff at the root
    # "nixpkgs-overlays=${../../..}/hosts/common/nix-path/overlay"
    # as long as my system itself doesn't rely on NIXPKGS at runtime, we can point the overlays to git
    # to avoid switching so much during development
    "nixpkgs-overlays=/home/colin/dev/nixos/hosts/common/nix-path/overlay"
  ];

  # ensure new deployments have a source of this repo with which they can bootstrap.
  # could get away with only shipping this on the `imgs.FOO` or `nixosSystems.rescue` targets, if we *really* want to save space/deploys.
  sane.fs."/etc/nix/source" = sane-lib.fs.wantedSymlinkTo ../../..;
}
