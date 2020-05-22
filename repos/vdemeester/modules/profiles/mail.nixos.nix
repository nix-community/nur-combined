{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.mail;
in
{
  options = {
    profiles.mail = {
      enable = mkOption {
        default = true;
        description = "Enable mail profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.etc."msmtprc".source = ../../assets/msmtprc;
    environment.systemPackages = with pkgs; [ msmtp ];
  };
}
