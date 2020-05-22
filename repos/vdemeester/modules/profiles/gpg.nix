{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.gpg;
in
{
  options = {
    profiles.gpg = {
      enable = mkOption {
        default = true;
        description = "Enable gpg profile and configuration";
        type = types.bool;
      };
      pinentry = mkOption {
        default = "${pkgs.pinentry}/bin/pinentry";
        description = "Path to pinentry";
        type = types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ gnupg ];
    services = {
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtlSsh = 7200;
        extraConfig = ''
          pinentry-program ${cfg.pinentry}
        '';
      };
    };
  };
}
