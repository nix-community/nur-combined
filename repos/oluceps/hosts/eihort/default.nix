{
  lib,
  inputs,
  user,
  ...
}:
{
  deployment = {
    targetHost = "10.0.1.6";
    targetPort = 22;
    targetUser = user;
    privilegeEscalationCommand = [
      "doas"
      "--"
    ];
  };

  imports = lib.sharedModules ++ [

    ./hardware.nix
    ./network.nix
    ./rekey.nix
    ./spec.nix
    ../../srv
    ../../age.nix
    ../../packages.nix
    ../../misc.nix
    ../../users.nix

    inputs.disko.nixosModules.default
  ];
}
