{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.sops-nix.homeManagerModules.sops
  ];
  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
      inputs.rust-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };
}
