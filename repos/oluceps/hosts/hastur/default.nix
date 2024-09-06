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
    # privilegeEscalationCommand = [
    #   "run0"
    #   "--"
    # ];
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
      # ../graphBase.nix

      ../persist.nix
      ../secureboot.nix
      ../../packages.nix
      ../../misc.nix
      ../sysvars.nix
      ../../age.nix

      ../sysctl.nix
      ../pam.nix
      ../virt.nix

      inputs.niri.nixosModules.niri
      ../../users.nix

      ./misskey.nix
      ../dev.nix
    ]
    ++ (with inputs; [
      aagl.nixosModules.default
      disko.nixosModules.default
      # niri.nixosModules.niri
      # nixos-cosmic.nixosModules.default
      # inputs.j-link.nixosModule
    ]);
}
