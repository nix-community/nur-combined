{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.services.fail2ban;
in {
  options.my.services.fail2ban = {
    enable = mkEnableOption "Enable fail2ban";
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      bantime-increment.enable = true;
      jails.DEFAULT = ''
        bantime = 6h
        findtime = 6h
      '';
    };
  };
}
