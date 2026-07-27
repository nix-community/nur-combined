{ inputs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.preservation.nixosModules.default
    inputs.vaultix.nixosModules.default
    inputs.fast-nix-gc.nixosModules.default
  ];
}
