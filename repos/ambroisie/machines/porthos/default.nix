# Porthos specific settings
{ ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
    ./users.nix
  ];
}
