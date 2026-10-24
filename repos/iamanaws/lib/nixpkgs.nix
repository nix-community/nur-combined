{ lib, outputs, ... }:
{
  nixpkgs = {
    config = import ./nixpkgsConfig.nix { inherit lib; };
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
  };
}
