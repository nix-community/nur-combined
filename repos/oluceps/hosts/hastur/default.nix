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
    privilegeEscalationCommand = [
      "doas"
      "--"
    ];
  };

  imports =
    lib.sharedModules
    ++ [
      ../../srv
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ./caddy.nix
      # ./nginx.nix
      ../graphBase.nix

      ../persist.nix
      ../secureboot.nix
      ../../packages.nix
      ../../misc.nix
      ../sysvars.nix
      ../../age.nix

      ../sysctl.nix

      inputs.niri.nixosModules.niri
      ../../users.nix

      inputs.misskey.nixosModules.default
      ./misskey.nix
    ]
    ++ (with inputs; [
      aagl.nixosModules.default
      disko.nixosModules.default
      attic.nixosModules.atticd
      # niri.nixosModules.niri
      nix-minecraft.nixosModules.minecraft-servers
      # inputs.j-link.nixosModule
    ]);
}
