{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    groups.nixers.name = "nixers";
  };
  nix.settings.trusted-users = [ "@nixers" ];
}
