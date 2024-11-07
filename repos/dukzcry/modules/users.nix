{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    users.users = {
      Artem = {
        uid = 1000;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.zsh;
      };
      Nina = {
        uid = 1001;
        isNormalUser = true;
      };
      video = {
        isNormalUser = true;
      };
    };
  };
}
