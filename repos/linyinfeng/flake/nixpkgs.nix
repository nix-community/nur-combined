{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.nvfetcher.overlays.default
  ];
}
