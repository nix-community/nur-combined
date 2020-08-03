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
    users.users.${config.mainUser} = {
      isNormalUser = true;
      packages = with pkgs; [ all-env ];
      extraGroups = [ "wheel" "networkmanager" "user-with-access-to-virtualbox" ];
    };
  };
}
