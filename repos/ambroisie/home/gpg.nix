{ config, lib, ... }:
let
  cfg = config.my.home.gpg;
in
{
  options.my.home.gpg = with lib.my; {
    enable = mkDisableOption "gpg configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true; # One agent to rule them all
      pinentryFlavor = "tty";
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };
  };
}
