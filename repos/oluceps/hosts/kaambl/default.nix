{
  lib,
  user,
  inputs,
  ...
}:
{
  deployment = {
    targetHost = "10.0.1.3";
    targetUser = user;
    allowLocalDeployment = true;
    privilegeEscalationCommand = [
      "doas"
      "--"
    ];
  };

  imports = lib.sharedModules ++ [
    ../../srv
    ./hardware.nix
    ./network.nix
    ./rekey.nix
    ./spec.nix
    ../persist.nix
    ../secureboot.nix
    inputs.home-manager.nixosModules.default
    ../../home
    ../sysctl.nix
    ../../age.nix
    ../../packages.nix
    ../../misc.nix
    ../../users.nix
    ../../sysvars.nix
    inputs.niri.nixosModules.niri
    ../graphBase.nix

    inputs.aagl.nixosModules.default
    inputs.disko.nixosModules.default
    inputs.tg-online-keeper.nixosModules.default
    # inputs.attic.nixosModules.atticd
    # inputs.factorio-manager.nixosModules.default
  ];
}
