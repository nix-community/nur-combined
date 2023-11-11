{ config, lib, ... }:
let
  cfg = config.my.home.mail.msmtp;
in
{
  config.programs.msmtp = lib.mkIf cfg.enable {
    enable = true;
  };
}
