{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    optionalString
    ;

  inherit (types) nullOr path attrs;

  cfg = config.services.mistserver;

  runtimeConfigFile = "${cfg.dataDir}/config.json";
  settingsFormat = pkgs.formats.json { };
  settingsJson = settingsFormat.generate "mistserver.json" cfg.settings;
in
{
  options.services.mistserver = {
    enable = mkEnableOption "mistserver, a streaming server";
    package = mkPackageOption pkgs "mistserver" { };
    openFirewall = mkEnableOption "opening the firewall for Mistserver";
    dataDir = mkOption {
      description = "The data directory for mistserver state and config files";
      type = path;
      default = "/var/lib/mistserver";
      example = "/path/to/mistserver";
    };
    settings = mkOption {
      description = ''
        Settings for the config.json file

        ::: {.warning}
        These settings will be world-readable, do not use for secrets!
        Instead, specify a config file in {option}`services.mistserver.configFile`.
        These settings get merged with {option}`services.mistserver.settings`.
        :::
      '';
      type = attrs;
      default = { };
    };
    configFile = mkOption {
      description = "Path to the mistserver config file";
      type = nullOr path;
      default = null;
      example = "/path/to/mistserver/config.json";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."mistserver" = {
      after = [ "network.target" ];
      description = "mistserver, a streaming server";
      wantedBy = [ "multi-user.target" ];
      preStart = optionalString (cfg.configFile != null) ''
        ${getExe pkgs.jq} -s 'reduce .[] as $obj ({}; . * $obj)' ${cfg.configFile} ${settingsJson} > ${runtimeConfigFile}
        chmod 0660 ${runtimeConfigFile}
      '';
      script = ''
        ${getExe cfg.package} -c ${runtimeConfigFile}
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        DynamicUser = true;
        RestartSec = 2;
        TimeoutStopSec = 8;
        TasksMax = "infinity";
        StateDirectory = "mistserver";
        UMask = "0027";
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        PrivateUsers = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        443 # HTTPS/HSLS
        1935 # RTMP
        4200 # DTSC
        4433 # Extra HTTPS/HSLS
        5554 # RTSP
        8080 # HTTP/HLS
      ];
      allowedUDPPorts = [
        8889 # SRT
        18203 # WebRTC
      ];
    };
  };
}
