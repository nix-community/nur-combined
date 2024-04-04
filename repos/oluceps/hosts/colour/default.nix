{ lib, user, ... }:
{
  deployment = {
    targetHost = "somehost.tld";
    targetPort = 22;
    targetUser = user;
  };

  imports = lib.sharedModules ++ [
    ./hardware.nix
    ./network.nix
    ./rekey.nix
    ./spec.nix
    ./caddy.nix
    ../../age.nix
    ../../packages.nix
    ../../misc.nix
    ../../users.nix
  ];
}
