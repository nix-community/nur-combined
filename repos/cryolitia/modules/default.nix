{ gpd-fan-driver, ... }:

{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;

  xdg-terminal-exec = ./xdg-terminal-exec.nix;
  gpd-fan-driver = gpd-fan-driver.nixosModules.default;
}
