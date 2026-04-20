{
  lib,
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
{
  imports = [
    inputs.nixcfg.modules.nixos.default
    "${inputs.nixos-unstable}/nixos/modules/profiles/qemu-guest.nix"
    inputs.catppuccin.nixosModules.catppuccin
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-avf.nixosModules.avf
    inputs.nixos-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  home-manager.users.toyvo.programs.beets.enable = lib.mkForce false;
  networking = {
    hostName = "pixel10a";
    networkmanager.enable = lib.mkForce false;
  };
  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
  userPresets.toyvo.enable = true;
  avf.defaultUser = "toyvo";
  users.users.toyvo.initialHashedPassword = lib.mkForce "";
}
