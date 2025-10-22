{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
{
  overlays.default = import ./pkgs/overlay.nix;
  modules = import ./nixos/default.nix;
}
// (import ./pkgs/default.nix { inherit pkgs; })
