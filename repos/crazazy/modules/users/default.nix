# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

with lib;
{
  options = {
    mainUser = mkOption {
      type = types.str;
      default = "erik";
      description = ''Name for the default user of the system'';
    };
  };

}
