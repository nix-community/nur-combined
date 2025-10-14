{ gpd-fan-driver, ... }:

{
  # Add your NixOS modules here

  gpd-fan-driver = gpd-fan-driver.nixosModules.default;
  bmi260 = ./bmi260.nix;
}
