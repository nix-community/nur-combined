{
  flake.overlays = (import ../default.nix { pkgs = null; }).overlays;
}
