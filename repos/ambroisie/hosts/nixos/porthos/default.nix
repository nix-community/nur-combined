# Porthos specific settings
{ ... }:

{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./home.nix
    ./networking.nix
    ./secrets
    ./services.nix
    ./system.nix
    ./users.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  system.stateVersion = "24.05"; # Did you read the comment?
}
