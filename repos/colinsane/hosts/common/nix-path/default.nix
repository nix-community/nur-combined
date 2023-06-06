{ pkgs, ... }:

{
  # allow `nix-shell` (and probably nix-index?) to locate our patched and custom packages
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    # note the import starts at repo root: this allows `./overlay/default.nix` to access the stuff at the root
    "nixpkgs-overlays=${../../..}/hosts/common/nix-path/overlay"
  ];
}
