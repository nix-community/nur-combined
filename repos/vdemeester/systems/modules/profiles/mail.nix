{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.mail;
  secretPath = ../../../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
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
  config = mkIf (cfg.enable && secretCondition) {
    environment.etc."msmtprc".source = pkgs.mkSecret ../../../secrets/msmtprc;
    environment.systemPackages = with pkgs; [ msmtp ];
  };
}
