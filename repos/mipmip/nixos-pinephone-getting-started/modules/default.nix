{ ... }:
{
  imports = [
    ./hardware.nix
    ./home-manager.nix
    ./phosh.nix
    ./users.nix
  ];

  system.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;
}
