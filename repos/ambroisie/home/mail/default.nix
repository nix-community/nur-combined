{ config, lib, ... }:
let
  cfg = config.my.home.mail;

  mkRelatedOption = desc: lib.mkEnableOption desc // { default = cfg.enable; };
in
{
  imports = [
    ./accounts.nix
    ./msmtp.nix
  ];

  options.my.home.mail = with lib; {
    enable = my.mkDisableOption "email configuration";

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
