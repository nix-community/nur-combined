{ config, lib, ... }:
let
  cfg = config.my.home.mail;

  mkRelatedOption = desc: lib.mkEnableOption desc // { default = cfg.enable; };
in
{
  imports = [
    ./accounts
    ./himalaya
    ./msmtp
  ];

  options.my.home.mail = with lib; {
    enable = my.mkDisableOption "email configuration";

    himalaya = {
      enable = mkEnableOption "himalaya configuration";
    };

    msmtp = {
      enable = mkRelatedOption "msmtp configuration";
    };
  };

  config = {
    accounts.email = {
      maildirBasePath = "mail";
    };
  };
}
