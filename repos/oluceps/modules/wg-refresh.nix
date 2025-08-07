{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkIf
    ;

  cfg = config.services.wg-refresh;
in
{
  options.services.wg-refresh = {
    enable = mkEnableOption { };
    calendar = mkOption {
      type = types.str;
      description = "sd timer";
    };
  };

  config = mkIf cfg.enable {
    systemd.timers.wg-refresh = {
      description = "intime switch power mode";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.calendar;
      };
    };
    systemd.services.wg-refresh = {
      wantedBy = [ "timer.target" ];
      description = "refresh outdate addr of wg dev";
      path = with pkgs; [
        iproute2
        systemd
        hostname
        dnsutils
        ripgrep
        iputils
      ];
      serviceConfig = {
        Type = "simple";
        User = "root";
        ExecStart = "${lib.getExe pkgs.nushell} ${../script/wg-refresh.nu} ${../registry.toml}";
        Restart = "no";
      };
    };
  };
}
