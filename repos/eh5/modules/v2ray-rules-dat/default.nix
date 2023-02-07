{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.v2ray-rules-dat;
  downloadDatCmd = name: url: ''
    ${pkgs.curl}/bin/curl -sL -o '${cfg.dataDir}/${name}' '${url}'
  '';
in
{
  options.services.v2ray-rules-dat = {
    enable = mkEnableOption "Auto update V2Ray rules dat";
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/v2ray-rules-dat";
    };
    updateUrls = mkOption {
      type = types.attrsOf types.str;
      default = {
        # "geoip.dat" = "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat";
        # "geosite.dat" = "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat";
        "geoip.dat" = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat";
        "geosite.dat" = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat";
      };
    };
    dates = mkOption {
      type = types.str;
      default = "6:30";
      example = "daily";
    };
    randomizedDelaySec = mkOption {
      default = "0";
      type = types.str;
      example = "30min";
    };
    reloadServices = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.v2ray-rules-dat = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      script = ''
        mkdir -p ${cfg.dataDir}
      '' + (
        concatStringsSep "\n" (mapAttrsToList downloadDatCmd cfg.updateUrls)
      );
      serviceConfig = {
        Type = "oneshot";
        ExecStartPost = mkIf (cfg.reloadServices != [ ]) [
          (pkgs.writeShellScript "v2ray-rules-dat-post" ''
            systemctl --no-block try-reload-or-restart ${escapeShellArgs cfg.reloadServices}
          '')
        ];
      };
    };
    systemd.timers.v2ray-rules-dat = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.dates;
        RandomizedDelaySec = cfg.randomizedDelaySec;
        Persistent = true;
      };
    };
  };
}
