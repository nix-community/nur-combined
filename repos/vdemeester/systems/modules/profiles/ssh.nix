{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.ssh;
in
{
  options = {
    profiles.ssh = {
      enable = mkOption {
        default = false;
        description = "Enable ssh profile";
        type = types.bool;
      };
      forwardX11 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to allow X11 connections to be forwarded.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        startWhenNeeded = false;
        forwardX11 = cfg.forwardX11;
        extraConfig = ''
          StreamLocalBindUnlink yes
        '';
      };
      sshguard.enable = true;
    };
    programs.mosh.enable = true;
  };
}
