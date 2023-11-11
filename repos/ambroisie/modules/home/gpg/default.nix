{ config, lib, ... }:
let
  cfg = config.my.home.gpg;
in
{
  options.my.home.gpg = with lib; {
    enable = my.mkDisableOption "gpg configuration";

    pinentry = mkOption {
      type = types.str;
      default = "tty";
      example = "gtk2";
      description = "Which pinentry interface to use";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true; # One agent to rule them all
      pinentryFlavor = cfg.pinentry;
      extraConfig = ''
        allow-loopback-pinentry
      '';
    };

    home.shellAliases = {
      # Sometime `gpg-agent` errors out...
      reset-agent = "gpg-connect-agent updatestartuptty /bye";
    };
  };
}
