{ ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/pine-home-manager.nix
    ../../modules/pine-phosh.nix
    ../../modules/pine-users.nix
  ];

  system.stateVersion = "22.05";
  nixpkgs.config.allowUnfree = true;
  #services.openssh.settings.PermitRootLogin = true;
}
