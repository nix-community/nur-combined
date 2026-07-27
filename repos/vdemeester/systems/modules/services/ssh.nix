{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.services.ssh;
in
{
  options = {
    modules.services.ssh = {
      enable = mkEnableOption "Enable ssh profile";
      listenAddresses = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      forwardX11 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to allow X11 connections to be forwarded.
        '';
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Verbatim contents of <filename>sshd_config</filename>.";
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        startWhenNeeded = false;
        settings = {
          X11Forwarding = cfg.forwardX11;
        };
        # listenAddresses = map
        # Move this for kerkouane only
        extraConfig = ''
          StreamLocalBindUnlink yes
          ${cfg.extraConfig}
        '';
      };
      sshguard.enable = true;
    };
    programs.mosh.enable = true;
  };
}
