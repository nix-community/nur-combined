{
  lib,
  user,
  inputs,
  ...
}:
{
  deployment = {
    targetHost = "10.0.1.2";
    targetPort = 22;
    buildOnTarget = true;
    allowLocalDeployment = true;
    targetUser = user;
  };

  imports =
    lib.sharedModules
    ++ [
      ../../services
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ./matrix.nix
      ./caddy.nix

      ../persist.nix
      ../secureboot.nix
      ../../packages.nix
      ../../misc.nix
      ../../sysvars.nix
      ../../age.nix

      ../sysctl.nix

      inputs.home-manager.nixosModules.default
      ../../home

      ../../users.nix

      inputs.misskey.nixosModules.default
      ./misskey.nix

      ./vaultwarden.nix
    ]
    ++ (with inputs; [
      aagl.nixosModules.default
      disko.nixosModules.default
      attic.nixosModules.atticd
      inputs.niri.nixosModules.niri
      # inputs.j-link.nixosModule
    ]);
}
