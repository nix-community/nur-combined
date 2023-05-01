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
    ./users.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
