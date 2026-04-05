{
  nixpkgs ? import ./nixpkgs.nix,
  config ? { },
  overlays ? [ ],
  ...
}@args:
import nixpkgs (
  {
    config = import ./nixpkgs-config.nix // config;
    overlays = [ (import ./pkgs) ] ++ overlays;
  }
  // removeAttrs args [
    "config"
    "overlays"
  ]
)
