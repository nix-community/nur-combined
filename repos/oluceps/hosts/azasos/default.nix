# JD cloud Mon  1 Apr 17:05:22 +08 2024
{ lib, user, inputs, ... }: {
  deployment = {
    targetHost = "116.196.112.43";
    targetPort = 22;
    targetUser = "root";
  };

  imports =
    lib.sharedModules ++ [

      inputs.disko.nixosModules.default
      ./hardware.nix
      ./network.nix
      ./rekey.nix
      ./spec.nix
      ../../age.nix
      ../../packages.nix
      ../../misc.nix
      ../../users.nix
    ];
}
