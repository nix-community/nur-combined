# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

with lib;
{
  imports =
    [
      # Include custom package environments
      ../packages-configuration
      ../vim-configuration
      # impermanences also belongs here i think
      ../tmpfs-configuration
    ];

  # main user option
  options = {
    mainUser = mkOption {
      type = types.str;
      default = "erik";
      description = ''Name for the default user of the system'';
    };
  };

  config = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.mutableUsers = false;
    users.users.root.initialHashedPassword = "e23b2e033ee1edca9314caba1ac8c7687f6115c41306985c16500b96f4c40381c69bbb311112c7b079f29cde2a6c2ac626a58ef25242a289a16abed0fc17f66d";
    users.users.${config.mainUser} = {
      initialHashedPassword = "$6$b2ubxLcnpU$zBz6y9/lCyxBXj4sV4qYLRCbyxtIBMACkZmyiysfr6GS5xF2G5jOyCTdE9Et6cKiArPSnIeuRgQZVtVC9goeR0";
      isNormalUser = true;
      packages = with pkgs; [ all-env ];
      extraGroups = [ "wheel" "networkmanager" "user-with-access-to-virtualbox" ];
    };
  };
}
