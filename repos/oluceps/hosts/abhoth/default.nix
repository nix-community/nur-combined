{ lib, user, ... }:
{
  deployment = {
    targetHost = "38.47.119.151";
    targetPort = 22;
    targetUser = user;
  };

  imports = lib.sharedModules ++ [
    ../../srv
    ../sysvars.nix
    ./hardware.nix
    ./network.nix
    ./rekey.nix
    ./spec.nix
    ../../age.nix
    ./caddy.nix
    # ../../packages.nix
    ../../misc.nix
    ../../users.nix
  ];
}
