# JD cloud Mon  1 Apr 17:05:22 +08 2024
{
  lib,
  inputs,
  user,
  ...
}:
{
  deployment = {
    targetHost = "116.196.112.43";
    targetPort = 22;
    targetUser = user;
  };

  imports = lib.sharedModules ++ [

    ../../services
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
