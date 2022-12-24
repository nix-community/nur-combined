{ config, lib, pkgs, ... }:

{
  users.extraGroups.docker.members = [ "bjorn" ];
  virtualisation.docker.enable = true;
}
